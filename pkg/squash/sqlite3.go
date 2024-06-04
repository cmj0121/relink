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

	sql_stmt := "INSERT INTO relink (key, value, creator_ip, password) VALUES (?, ?, ?, ?)"
	password := sql.NullString{}
	if record.Password != nil && *record.Password != "" {
		password = sql.NullString{String: *record.Password, Valid: true}
	}

	_, err := s.db.Exec(sql_stmt, record.Hashed, record.Source, record.IP, password)
	if err != nil {
		log.Warn().Err(err).Str("record", record.String()).Msg("failed to save the key-value pair")
		return err
	}

	return nil
}

// search the value by the key
func (s *SQLite) SearchSource(key string) *types.Record {
	s.mu.RLock()
	defer s.mu.RUnlock()

	row := s.db.QueryRow("SELECT key, value, creator_ip, created_at, password FROM relink WHERE key = ?", key)
	return types.NewFromRow(row)
}

// search the key by the value
func (s *SQLite) SearchHashed(value string) *types.Record {
	s.mu.RLock()
	defer s.mu.RUnlock()

	row := s.db.QueryRow("SELECT key, value, creator_ip, created_at, password FROM relink WHERE value = ?", value)
	return types.NewFromRow(row)
}

// list all the records
func (s *SQLite) List(ctx context.Context) <-chan *types.Record {
	ch := make(chan *types.Record)

	go func() {
		s.mu.RLock()
		defer s.mu.RUnlock()
		defer close(ch)

		rows, err := s.db.Query("SELECT key, value, creator_ip, created_at, password FROM relink ORDER BY created_at DESC")
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
