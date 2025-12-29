# frozen_string_literal: true

$LOAD_PATH << '.'

require 'rubygems'
require 'player'
require 'point'
require 'active_support/core_ext/hash/indifferent_access'
require 'json'
require 'pry'

# An instance of this class represents a game board with
# a distinct points configuration, and one or more registered
# players positioned within the logical coordinate plane.
class Board
  WIDTH = 800   # unit width of the board
  HEIGHT = 600  # unit height of the board

  attr_accessor :players  # players positioned on board
  attr_accessor :points   # points allocated to the board

  # Sets up this board with an empty list of registered
  # players and a predefined points configuration
  def initialize
    @players = []
    @points = generate_points
  end

  # Adds a player to the board
  def add_player(player)
    @players << player
  end

  # Removes a player from the board
  def remove_player(player_id)
    @players.delete_if do |player|
      player.id == player_id
    end
  end

  # Generates and returns a predefined points configuration
  def generate_points
    points = [
      Point.new(0, 0), Point.new(1, 0), Point.new(2, 0),
      Point.new(0, 1), Point.new(1, 1), Point.new(2, 1),
      Point.new(0, 2), Point.new(1, 2), Point.new(2, 2)
    ]
    # Map the local point coordinates to unit x and y
    # coordinate values
    points.each do |point|
      point.x = 110 + point.column * 250
      point.y = 75 + point.row * 200
    end
    points
  end

  # Determines whether the board is empty with respect to
  # allocated points. If all points have been awarded to
  # one or more players the board will in effect be empty.
  def empty?
    @points.empty?
  end

  # Determines whether the supplied player is positioned
  # on the leading x edge of the board.
  def at_leading_edge_x?(player)
    player.x <= 0
  end

  # Determines whether the supplied player is positioned
  # on the trailing x edge of the board.
  def at_trailing_edge_x?(player)
    player.x + Player::WIDTH >= WIDTH
  end

  # Determines whether the supplied player is positioned
  # on the leading or trailing x edge of the board.
  def at_edge_x?(player)
    at_leading_edge_x?(player) || at_trailing_edge_x?(player)
  end

  # Determines whether the supplied player is positioned
  # on the leading y edge of the board.
  def at_leading_edge_y?(player)
    player.y <= 0
  end

  # Determines whether the supplied player is positioned
  # on the trailing y edge of the board.
  def at_trailing_edge_y?(player)
    player.y + Player::HEIGHT >= HEIGHT
  end

  # Determines whether the supplied player is positioned
  # on the leading or trailing y edge of the board.
  def at_edge_y?(player)
    at_leading_edge_y?(player) || at_trailing_edge_y?(player)
  end

  # Determines whether the supplied player is positioned
  # on the leading or trailing x edge of the board, or
  # positioned on the leading or trailing y edge of the
  # board.
  def at_edge?(player)
    at_edge_x?(player) || at_edge_y?(player)
  end

  # Determines and returns a list of those other players
  # that the supplied player has collided with. If the
  # supplied player is not deemed to have collided with
  # other players an empty array will be returned.
  def collided_with_players(player, players)
    hit_players = []
    @players.each do |other_player|
      if player.id != other_player.id &&
         (player.x < other_player.x + Player::WIDTH && player.x + Player::WIDTH > other_player.x &&
         player.y < other_player.y + Player::HEIGHT && player.y + Player::HEIGHT > other_player.y)
        hit_players << other_player
      end
    end
    hit_players
  end

  # Determines and returns the point to award to the
  # supplied player if it is determined that this player
  # has in fact collided with a point. If the supplied
  # player has not collided with a point nil will be
  # returned.
  def collided_with_point(player)
    awarded_point = nil
    @points.each do |point|
      if player.x < point.x + Point::WIDTH && player.x + Player::WIDTH > point.x &&
         player.y < point.y + Point::HEIGHT && player.y + Player::HEIGHT > point.y
        awarded_point = point
      end
    end
    awarded_point
  end

  # Updates the player state using the pertinent information
  # found in the supplied data hash. This includes moving the
  # player on the board, as well as enforcing restrictions on
  # players not moving beyond the bounds of the board, as well
  # as general detection of boundary conditions.
  def update_player(data)
    player = @players.find { |p| p.id == data[:id] }
    player.move(data[:dir])
    # Prevent movement beyond edges of board
    player.x = 0 if at_leading_edge_x?(player)
    player.x = WIDTH - Player::WIDTH if at_trailing_edge_x?(player)
    player.y = 0 if at_leading_edge_y?(player)
    player.y = HEIGHT - Player::HEIGHT if at_trailing_edge_y?(player)
  end

  # Resets all points currently awarded to the supplied player,
  # and reallocates them back to the board to their respective
  # logical positions. Other registered players can be awarded
  # these points after calling this method.
  def reset_player_points!(player)
    lost_points = player.reset_points!
    @points.concat(lost_points)
  end

  # Evaluates the current state of the board, including checking
  # for player collisions, player edge collision, point awarding,
  # and point redistribution back to the board.
  def evaluate_board
    @players.each do |player|
      # Check for edge collisions
      if at_edge?(player)
        player.at_edge = true
        reset_player_points!(player)
      else
        player.at_edge = false
      end
      # Check for player collisions
      hit_players = collided_with_players(player, @players)
      if !hit_players.nil? && !hit_players.empty?
        lost_points = player.hit!
        @points.concat(lost_points)
        hit_players.each do |p|
          lost_points = p.hit!
          @points.concat(lost_points)
        end
      else
        player.hit = false
      end
      awarded_point = collided_with_point(player)
      if !awarded_point.nil?
        player.awarded_point = true
        player.points << awarded_point
        @points.delete(awarded_point)
      else
        player.awarded_point = false
      end
    end
  end

  # Evaluates the current state of the board, by first updating
  # the relative state of the player using the pertinent information
  # found in the supplied data hash, and then performing a full
  # evaluation of the overall board state.
  def evaluate(data)
    update_player(data)
    evaluate_board
  end

  # Returns a hash representation of this board object.
  def to_hash
    {
      points: @points.map { |p| p.to_hash },
      players: @players.map { |p| p.to_hash }
    }
  end
end
