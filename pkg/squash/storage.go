package squash

import (
	"fmt"
	"net/url"

	"github.com/rs/zerolog/log"
)

type Storager interface {
	Save(key, value string) error
	SearchValue(key string) (string, bool)
	SearchKey(value string) (string, bool)
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
	default:
		err := fmt.Errorf("unsupported scheme: %s", url.Scheme)
		log.Warn().Err(err).Str("scheme", url.Scheme).Msg("unsupported scheme")
		return err
	}

	return err
}
