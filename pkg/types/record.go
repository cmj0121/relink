package types

import (
	"database/sql"
	"fmt"
	"time"

	"github.com/rs/zerolog/log"
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

func NewFromRow(row *sql.Row) *Record {
	var record Record

	switch err := row.Scan(&record.Hashed, &record.Source, &record.CreatedAt); err {
	case nil:
		return &record
	case sql.ErrNoRows:
		return nil
	default:
		log.Warn().Err(err).Msg("failed to scan the row")
		return nil
	}
}

func NewFromRows(rows *sql.Rows) *Record {
	var record Record

	switch err := rows.Scan(&record.Hashed, &record.Source, &record.CreatedAt); err {
	case nil:
		return &record
	case sql.ErrNoRows:
		return nil
	default:
		log.Warn().Err(err).Msg("failed to scan the row")
		return nil
	}
}

func (r *Record) String() string {
	return fmt.Sprintf("[%v] %s -> %s", r.CreatedAt, r.Source, r.Hashed)
}
