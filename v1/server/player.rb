# frozen_string_literal: true

$LOAD_PATH << '.'

require 'json'

# An instance of this class represents a player in the game
class Player
  WIDTH = 50                    # unit width of a player
  HEIGHT = 50                   # unit height of player
  MOVE_INCREMENT = WIDTH / 2.5  # increment a player moves by

  attr_accessor :id             # unique id of player
  attr_accessor :color          # unique color of player
  attr_accessor :x              # current x coordinate position
  attr_accessor :y              # current y coordinate position
  attr_accessor :at_edge        # flag indicating if player is at edge of board
  attr_accessor :hit            # flag indicating if player has hit another player
  attr_accessor :awarded_point  # flag indicating if player has been awarded a point
  attr_accessor :points         # list of points awarded to this player

  # Establishes the starting state for a new player, including
  # the starting coordinate position on the board, and where
  # the player starts with zero points awarded.
  def initialize
    @x = 0
    @y = 0
    @at_edge = false
    @hit = false
    @awarded_point = false
    @points = []
  end

  # Moves the player in the specified direction by the default
  # move increment. The supplied direction must be one of n
  # for north, s for south, e for east, or w for west.
  def move(direction)
    case direction.to_sym
    when :n
      @y = @y - MOVE_INCREMENT
    when :s
      @y = @y + MOVE_INCREMENT
    when :e
      @x = @x + MOVE_INCREMENT
    when :w
      @x = @x - MOVE_INCREMENT
    end
  end

  # Records a hit on this player representing a situation where
  # this player has hit another player, or where another player
  # has hit this player. The hit flag will be set on this player
  # indicating that a hit has occured, and all points will be
  # reset on this player.
  def hit!
    @hit = true
    reset_points!
  end

  # Resets this players points leaving the player without any
  # points awarded. If this player had one or more points
  # previously awarded, they will be returned from this method
  # indicating those points lost by the reset.
  def reset_points!
    lost_points = []
    @points.each do |point|
      lost_points << point
    end
    @points.clear
    lost_points
  end

  # Returns an integer value representing the score currently
  # held by this player with respect to the points awarded.
  # If no points have been awarded the returned score will be
  # zero, otherwise the respective point values will be totaled.
  def score
    @points.inject(0) { |sum, p| sum + p.value }
  end

  # Returns a hash representation of this player.
  def to_hash
    {
      id: @id,
      color: @color,
      x: @x,
      y: @y,
      at_edge: @at_edge,
      hit: @hit,
      awarded_point: @awarded_point,
      points: @points.map { |p| p.to_hash },
      score: score
    }
  end
end
