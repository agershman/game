package game

import "testing"

func TestNewPoint(t *testing.T) {
	point := newPoint(0, 0, 0)
	if point.value != DefaultPointValue {
		t.Errorf("Expected point value to be %d, got %d", DefaultPointValue, point.value)
	}
}
