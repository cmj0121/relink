package types

import (
	"fmt"
	"time"
)

type Record struct {
	// the source of the link
	Source string

	// the squashed link
	Hashed string

	// the algorithm to squash the link
	Algo string

	// the timestamp mixed with the source
	CreatedAt time.Time
	UpdatedAt *time.Time
	DeletedAt *time.Time
}

// Create a new instance of Record with the default settings.
func New(source, hashed, algo string) *Record {
	return &Record{
		Source:    source,
		Hashed:    hashed,
		Algo:      algo,
		CreatedAt: time.Now(),
	}
}

func (r *Record) String() string {
	return fmt.Sprintf("[%v] %s -> %s", r.CreatedAt, r.Source, r.Hashed)
}
