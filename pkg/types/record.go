package types

import (
	"time"
)

type Record struct {
	// the source of the link
	Source string

	// the squashed link
	Squashed string

	// the algorithm to squash the link
	Algo string

	// the timestamp mixed with the source
	CreatedAt time.Time
	UpdatedAt *time.Time
	DeletedAt *time.Time
}
