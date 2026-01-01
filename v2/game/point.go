package game

const (
	DefaultPointValue int = 1  // default point value
	PointWidth        int = 50 // unit width of a point
	PointHeight       int = 50 // unit height of a point
)

// An instance of this class represents a point within the
// game that can be awarded to a player.
type point struct {
	value  int // value assigned to this point
	column int // logical column position
	row    int // logical row position
	x      int // current x coordinate position
	y      int // current y coordinate position
}

// Establishes the point value and logical column and row
// positions for this point. If a point value is not supplied
// the default point value will be applied.
func newPoint(value int, column int, row int) point {
	if value == 0 {
		value = DefaultPointValue
	}
	return point{value: value, column: column, row: row}
}
