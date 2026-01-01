package game

const (
	PlayerWidth         int = 50
	PlayerHeight        int = 50
	PlayerMoveIncrement int = PlayerWidth * 1
)

type player struct {
	id           string
	color        string
	x            int
	y            int
	atEdge       bool
	isHit        bool
	awardedPoint bool
	points       []point
}

func newPlayer() player {
	return player{
		x:            0,
		y:            0,
		atEdge:       false,
		isHit:        false,
		awardedPoint: false,
		points:       nil,
	}
}

func (p *player) move(direction string) {
	switch direction {
	case "n":
		p.y -= PlayerMoveIncrement
	case "s":
		p.y += PlayerMoveIncrement
	case "e":
		p.x += PlayerMoveIncrement
	case "w":
		p.x -= PlayerMoveIncrement
	}
}

func (p *player) hit() []point {
	pointsBeforeHit := p.points
	p.isHit = true
	p.resetPoints()
	return pointsBeforeHit
}

func (p *player) resetPoints() {
	p.points = nil
}

func (p *player) score() int {
	score := 0
	for _, p := range p.points {
		score += p.value
	}
	return score
}
