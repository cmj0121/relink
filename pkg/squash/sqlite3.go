package squash

import (
	"database/sql"
	"fmt"
	"net/url"
	"sync"

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
func (s *SQLite) Save(key, value string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	_, err := s.db.Exec("INSERT INTO relink (key, value) VALUES (?, ?)", key, value)
	if err != nil {
		log.Warn().Err(err).Str("key", key).Str("value", value).Msg("failed to save the key-value pair")
		return err
	}

	return nil
}

// search the value by the key
func (s *SQLite) SearchValue(key string) (string, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	var value string
	err := s.db.QueryRow("SELECT value FROM relink WHERE key = ?", key).Scan(&value)
	switch {
	case err == sql.ErrNoRows:
		return "", false
	case err != nil:
		log.Warn().Err(err).Str("key", key).Msg("failed to search the value")
		return "", false
	}

	return value, true
}

// search the key by the value
func (s *SQLite) SearchKey(value string) (string, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	var key string
	err := s.db.QueryRow("SELECT key FROM relink WHERE value = ?", value).Scan(&key)
	switch {
	case err == sql.ErrNoRows:
		return "", false
	case err != nil:
		log.Warn().Err(err).Str("value", value).Msg("failed to search the key")
		return "", false
	}

	return key, true
}
