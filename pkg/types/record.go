package types

import (
	"database/sql"
	"fmt"
	"time"

	"github.com/rs/zerolog/log"
)

type Record struct {
	Source string  `json:"source"`
	Hashed string  `json:"hashed"`
	Algo   string  `json:"algo"`
	IP     *string `json:"ip"`

	// The password to protect the link
	Password *string `json:"-"`

	// the timestamp mixed with the source
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt *time.Time `json:"updated_at"`
	DeletedAt *time.Time `json:"deleted_at"`
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
	var clientIP sql.NullString
	var password sql.NullString

	switch err := row.Scan(&record.Hashed, &record.Source, &clientIP, &record.CreatedAt, &password); err {
	case nil:
		record.IP = &clientIP.String
		record.Password = &password.String
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
	var clientIP sql.NullString
	var password sql.NullString

	switch err := rows.Scan(&record.Hashed, &record.Source, &clientIP, &record.CreatedAt, &password); err {
	case nil:
		record.IP = &clientIP.String
		record.Password = &password.String
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
