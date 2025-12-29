# frozen_string_literal: true

$LOAD_PATH << '.'

require 'rubygems'
require 'eventmachine'
require 'em-websocket'
require 'active_support/core_ext/hash/indifferent_access'
require 'json'
require 'pry'

# An instance of this class represents a server capable of
# hosting a game instance, and both receiving inbound data
# sent from one or more controllers, as well as pushing
# outbound state updates of the game to one or more clients.
class Server
  HOST = '0.0.0.0'          # local address to bind sockets to
  VIEW_PORT = 8080          # outbound view websocket port
  CONTROL_PORT = 8181       # inbound control websocket port

  # Initializes the server with the supplied game
  # instance
  def initialize(game)
    @view_sockets = []
    @game = game
  end

  # Starts the server including the control port
  # and view port.
  def start
    EventMachine.run do
      start_control_port
      start_view_port
    end
  end

  # Starts the WebSocket for receiving control input
  # (directions and commands) from one or more controls
  def start_control_port
    EventMachine::WebSocket.run(host: HOST, port: CONTROL_PORT) do |ws|
      ws.onopen do
        puts 'Control connected.'
      end

      ws.onmessage do |msg|
        puts "Control input: #{msg}"
        # Inbound data protocol (json):
        #
        #   {
        #     "id": "...",
        #     "dir": "n|s|e|w",
        #     "cmd": "n|q"
        #   }
        #
        #   where "id" = player id
        #
        #   where "dir":
        #     "n" = north
        #     "s" = south
        #     "e" = east
        #     "w" = west
        #
        #   where "cmd":
        #     "n" = new game
        #     "q" = player quit
        data = JSON.parse(msg).with_indifferent_access
        # Evaluate the next state of the game
        @game.evaluate(data)
        # Send the updated game state to all view clients
        @view_sockets.each do |view_ws|
          view_ws.send(@game.to_json)
        end
      end

      ws.onclose do
        puts 'Control disconnected.'
      end
    end
    puts "Control listening on #{HOST}:#{CONTROL_PORT}"
  end

  # Starts WebSocket for pushing game state updates out to
  # one or more registered view clients
  def start_view_port
    EventMachine::WebSocket.run(host: HOST, port: VIEW_PORT) do |ws|
      ws.onopen do
        @view_sockets << ws
        puts 'View client connected.'
      end

      ws.onclose do
        @view_sockets.delete(ws)
        puts 'View client disconnected.'
      end
    end
    puts "View listening on #{HOST}:#{VIEW_PORT}"
  end
end
