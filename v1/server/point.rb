# frozen_string_literal: true

$LOAD_PATH << '.'

require 'board'

# An instance of this class represents a point within the
# game that can be awarded to a player.
class Point
  DEFAULT_VALUE = 1  # default point value
  WIDTH = 50         # unit width of a point
  HEIGHT = 50        # unit height of a point

  attr_accessor :value   # value assigned to this point
  attr_accessor :column  # logical column position
  attr_accessor :row     # logical row position
  attr_accessor :x       # current x coordinate position
  attr_accessor :y       # current y coordinate position

  # Establishes the point value and logical column and row
  # positions for this point. If a point value is not supplied
  # the default point value will be applied.
  def initialize(column, row, value = DEFAULT_VALUE)
    @value = value
    @column = column
    @row = row
  end

  # Returns a hash representation of this point object.
  def to_hash
    {
      value: 1,
      column: @column,
      row: @row,
      x: @x,
      y: @y
    }
  end
end
