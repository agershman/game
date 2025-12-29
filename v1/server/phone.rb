# frozen_string_literal: true

$LOAD_PATH << '.'

require 'rubygems'
require 'websocket-client-simple'
require 'json'
require 'server'
require 'optparse'
require 'ostruct'

# An instance of this class represents a mobile phone that
# knows how to send directional data and other game commands
# to a well known game server.
class Phone
  attr_accessor :id  # unique id of phone

  # Sets up this phone with an outbound WebSocket connection
  # to the game server for sending directional events and/or
  # game commands. The phone must be given an identifier.
  def initialize(id)
    @id = id
    @connected = false
    @ws = WebSocket::Client::Simple.connect("ws://#{Server::HOST}:#{Server::CONTROL_PORT}")

    phone = self
    @ws.on :open do
      phone.instance_variable_set(:@connected, true)
    end

    @ws.on :error do |e|
      puts "WebSocket error: #{e.message}"
    end

    @ws.on :close do
      phone.instance_variable_set(:@connected, false)
    end

    # Wait for connection to establish
    sleep 0.1 until @connected
  end

  # Sends the supplied directional signal to the game server.
  def send_direction(direction)
    data = { id: @id, dir: direction }
    @ws.send(data.to_json)
  end

  # Sends the supplied command to the game server.
  def send_command(command)
    data = { id: @id, cmd: command }
    @ws.send(data.to_json)
  end

  # Closes the WebSocket connection.
  def close
    @ws.close
  end

  # Sends the quit command to the game server for this phone.
  def quit!
    send_command :q
  end

  # Sends the north direction signal to the game server for
  # this phone.
  def n
    send_direction :n
  end

  # Sends the south direction signal to the game server for
  # this phone.
  def s
    send_direction :s
  end

  # Sends the east direction signal to the game server for
  # this phone.
  def e
    send_direction :e
  end

  # Sends the west direction signal to the game server for
  # this phone.
  def w
    send_direction :w
  end
end

# Simple CLI program to emulate a phone controller
options = OpenStruct.new
options.verbose = false
options.id = nil
options.direction = nil
options.multiplier = 1
options.command = nil

# Command line options parser definition
opts = OptionParser.new do |opts|
  opts.banner = 'Usage: phone.rb [options]'

  opts.separator ''
  opts.separator 'Specific options:'

  # id
  opts.on('-i', '--id ID', 'Identifer of phone.') do |id|
    options.id = id
  end

  # direction
  opts.on('-d', '--direction DIR', 'Direction to send to game server.') do |dir|
    options.direction = dir
  end

  # multiplier
  opts.on('-m', '--multiplier [MUL]', 'Direction multiplier.') do |mul|
    options.multiplier = mul.to_i
  end

  # command
  opts.on('-c', '--command [CMD]', 'Command to send to game server.') do |cmd|
    options.command = cmd
  end

  # verbose
  opts.on('-v', '--[no-]verbose', 'Run verbosely.') do |v|
    options.verbose = v
  end

  opts.separator ''
  opts.separator 'Common options:'

  # help
  opts.on_tail('-h', '--help', 'Show this message.') do
    puts opts
    exit
  end
end
opts.parse!(ARGV)
options

# Validate the parsed command line options
invalid = false
if options.id.nil? || options.id.empty?
  puts 'A phone identifier must be supplied.'
  invalid = true
elsif (options.direction.nil? || options.direction.empty?) &&
      (options.command.nil? || options.command.empty?)
  puts 'A direction or command must be supplied.'
  invalid = true
end
if invalid
  puts opts
  exit
end

# Use phone given the parsed options
phone = Phone.new(options.id)
begin
  if !options.command.nil?
    phone.send_command(options.command)
  else
    options.multiplier.times do
      phone.send_direction(options.direction)
    end
  end
  # Give time for message to be sent before closing
  sleep 0.1
ensure
  phone.close
end
