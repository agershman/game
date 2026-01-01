package game

import (
	"testing"
)

func TestPlayerMove(t *testing.T) {
	moves := []struct {
		direction string
		expectedX int
		expectedY int
	}{
		{
			direction: "n",
			expectedX: 100,
			expectedY: 50,
		},
		{
			direction: "s",
			expectedX: 100,
			expectedY: 150,
		},
		{
			direction: "e",
			expectedX: 150,
			expectedY: 100,
		},
		{
			direction: "w",
			expectedX: 50,
			expectedY: 100,
		},
	}

	for _, move := range moves {
		player := newPlayer()
		player.x = 100
		player.y = 100
		player.move(move.direction)
		if player.x != move.expectedX {
			t.Errorf("Expected player x value to be %d, got %d", move.expectedX, player.x)
		}
		if player.y != move.expectedY {
			t.Errorf("Expected player y value to be %d, got %d", move.expectedY, player.y)
		}
	}
}

func TestPlayerHit(t *testing.T) {
	player := newPlayer()
	player.points = append(player.points, newPoint(1, 0, 0))
	lostPoints := player.hit()
	if !player.isHit {
		t.Error("Expected player to be hit.")
	}
	if len(player.points) != 0 {
		t.Error("Expected player points to be reset.")
	}
	if len(lostPoints) != 1 {
		t.Error("Expected player to lose 1 point.")
	}
}

func TestPlayerScore(t *testing.T) {
	player := newPlayer()
	player.points = append(player.points,
		newPoint(1, 0, 0),
		newPoint(1, 0, 1),
		newPoint(1, 0, 2),
	)
	expectedScore := 3
	actualScore := player.score()
	if actualScore != expectedScore {
		t.Errorf("Expected player score to be %d, got %d", expectedScore, actualScore)
	}
}
