package squash

import (
	"context"
	"database/sql"
	"fmt"
	"net/url"
	"sync"

	"github.com/cmj0121/relink/pkg/types"
	_ "github.com/mattn/go-sqlite3"
	"github.com/rs/zerolog/log"
)

type SQLite struct {
	mu sync.RWMutex

	db *sql.DB
}

func NewSQLite(url *url.URL) (*SQLite, error) {
	path := fmt.Sprintf("%s/%s", url.Host, url.Path)
	db, err := sql.Open("sqlite3", path)
	if err != nil {
		log.Warn().Err(err).Str("path", path).Msg("failed to open the database")
		return nil, err
	}

	if err := db.Ping(); err != nil {
		log.Warn().Err(err).Str("path", path).Msg("failed to ping the database")
		return nil, err
	}

	s := &SQLite{db: db}
	return s, nil
}

// save the key-value pair to the storage
func (s *SQLite) Save(record *types.Record) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	_, err := s.db.Exec("INSERT INTO relink (key, value) VALUES (?, ?)", record.Hashed, record.Source)
	if err != nil {
		log.Warn().Err(err).Str("record", record.String()).Msg("failed to save the key-value pair")
		return err
	}

	return nil
}

// search the value by the key
func (s *SQLite) SearchSource(key string) (string, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	row := s.db.QueryRow("SELECT * FROM relink WHERE key = ?", key)
	switch record := types.NewFromRow(row); record {
	case nil:
		return "", false
	default:
		return record.Source, true
	}
}

// search the key by the value
func (s *SQLite) SearchHashed(value string) (string, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	row := s.db.QueryRow("SELECT * FROM relink WHERE value = ?", value)
	switch record := types.NewFromRow(row); record {
	case nil:
		return "", false
	default:
		return record.Hashed, true
	}
}

// list all the records
func (s *SQLite) List(ctx context.Context) <-chan *types.Record {
	ch := make(chan *types.Record)

	go func() {
		s.mu.RLock()
		defer s.mu.RUnlock()
		defer close(ch)

		rows, err := s.db.Query("SELECT * FROM relink")
		if err != nil {
			log.Warn().Err(err).Msg("failed to list the records")
			return
		}
		defer rows.Close()

		for rows.Next() {
			record := types.NewFromRows(rows)

			select {
			case <-ctx.Done():
				return
			case ch <- record:
			}
		}
	}()

	return ch
}
