# frozen_string_literal: true

$LOAD_PATH << '.'

require 'server'
require 'board'
require 'player'
require 'pry'

# An instance of this class represents a single game session,
# configured with a game board and one or more registered
# players. A game is either started or has ended, and if it
# has ended a winner is selected based on the highest score.
class Game
  attr_accessor :board    # the game board
  attr_accessor :status   # the current status of the game
  attr_accessor :winner   # the selected game winner
  attr_accessor :players  # the registered players

  # Starts the game off with a default state setup, including
  # an empty collection of registered players, a default board
  # configuration, and with the status as :started.
  def initialize
    reset!
  end

  # Resets the game for a new play session, including an empty
  # collection of registered players, a default board configuration,
  # and the status set back to :started.
  def reset!
    @players = {}
    @board = Board.new
    @status = :started
    @winner = nil
    puts 'Reset new game.'
  end

  # Registers a player to the game and also registers them with
  # the underlying game board. Players are registered by their
  # supplied unique id.
  def register_player(data)
    player_id = data[:id]
    player = Player.new
    player.id = player_id
    @players[player_id] = player
    # Add player to the board
    @board.add_player(player)
    puts "Registered player: #{player_id}"
    player
  end

  # Unregisters a player from the game and also unregisters them
  # from the underlying game board.
  def unregister_player(player_id)
    player = @players[player_id]
    # Reset the players points
    @board.reset_player_points!(player)
    # Remove player from board
    @board.remove_player(player_id)
    # Remove the player from the game
    @players.delete(player_id)
    puts "Unregistered player: #{player_id}"
  end

  # Evaluates the current state of the game based on the supplied
  # data hash, including registering new players, evaluating commands
  # such as requests to start a new game or players quiting, as well
  # as determining the conditions necessary to indicate the game being
  # over and selecting a winner.
  def evaluate(data)
    # Register new players
    player_id = data[:id]
    player = @players[player_id]
    if player.nil?
      player = register_player(data)
    end
    # Evaluate any sent commands
    if data.key?(:cmd) && !data[:cmd].nil?
      case data[:cmd].to_sym
      when :n
        reset!
        return # skip board evaluation
      when :q
        unregister_player(player.id)
        return # skip board evaluation
      else
        puts "Received unknown command '#{command}' from player: #{player.id}"
      end
    end
    # Evaluate the current state of the board
    @board.evaluate(data)
    # When all points are off the board the game is over
    if @board.empty?
      # Winner has the highest score
      @winner = @players.values.max_by { |p| p.score }
      @status = :ended
      puts "Game ended. Winner is: #{@winner}"
    end
  end

  # Returns a hash representation of the game.
  def to_json
    {
      status: @status,
      winner: !@winner.nil? ? @winner.to_hash : nil,
      board: @board.to_hash
    }.to_json
  end
end

# Start the game server
game = Game.new
server = Server.new(game)
server.start
