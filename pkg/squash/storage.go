package squash

import (
	"context"
	"fmt"
	"net/url"

	"github.com/cmj0121/relink/pkg/types"
	"github.com/rs/zerolog/log"
)

type Storager interface {
	Save(record *types.Record) error

	SearchSource(key string) *types.Record
	SearchHashed(key string) *types.Record

	List(ctx context.Context) <-chan *types.Record
}

type Storage struct {
	Storager
}

func NewStorage() *Storage {
	return &Storage{}
}

// unmarshal the text to the storage
func (s *Storage) UnmarshalText(_text []byte) error {
	text := string(_text)
	url, err := url.Parse(text)
	if err != nil {
		log.Warn().Err(err).Str("text", text).Msg("failed to parse the URL")
		return err
	}

	switch url.Scheme {
	case "memory", "mem":
		s.Storager, err = NewMem()
	case "sqlite3", "sqlite":
		s.Storager, err = NewSQLite(url)
		if err == nil {
			m := types.Migrate{Database: text}
			if err := m.Run(); err != nil {
				log.Warn().Err(err).Str("database", text).Msg("failed to migrate the database")
				return err
			}
		}
	default:
		err := fmt.Errorf("unsupported scheme: %s", url.Scheme)
		log.Warn().Err(err).Str("scheme", url.Scheme).Msg("unsupported scheme")
		return err
	}

	return err
}
