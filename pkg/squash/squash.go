package squash

import (
	"fmt"
	"net/url"

	"github.com/cmj0121/relink/pkg/squash/algo"
	"github.com/cmj0121/relink/pkg/types"
	"github.com/rs/zerolog/log"
)

const (
	// The default base URL to squash the link.
	DEFAULT_BASE_URL = "https://401.tw"
)

// The instance to squash the link and make it shorter.
type Squash struct {
	Storage    *Storage        `short:"S" default:"sqlite3://relink.sql" help:"The storage to save the squashed link."`
	BaseURL    *url.URL        `short:"u" default:"https://401.tw" help:"The base URL to squash the link."`
	MinSize    int             `short:"m" default:"4" help:"The minimum size of the squashed link."`
	MaxSize    int             `short:"M" default:"8" help:"The maximum size of the squashed link."`
	SquashAlgo algo.SquashAlgo `short:"a" default:"hash" help:"The algorithm to squash the link."`

	Source string `arg:"" optional:"" help:"The source of the link."`
}

// Create a new instance of Squash with the default settings.
func New() *Squash {
	baseURL, _ := url.Parse(DEFAULT_BASE_URL)

	return &Squash{
		Storage: NewStorage(),
		BaseURL: baseURL,
		MaxSize: 8,
	}
}

// Parse the arguments and options from the command line, and run the command.
func (s *Squash) Run() error {
	log.Info().Str("source", s.Source).Msg("squash the link")
	squashed, err := s.SquashToLink(s.Source, "", nil)
	if err != nil {
		return err
	}

	log.Info().Str("source", s.Source).Str("squashed", squashed).Msg("squashed the link")
	fmt.Println(squashed)
	return nil
}

// Squash the link and make it shorter.
func (s *Squash) SquashToLink(link string, passwd string, remote *string) (string, error) {
	source, err := url.Parse(link)
	if err != nil {
		log.Warn().Err(err).Str("link", link).Msg("failed to parse the link")
		return "", err
	}

	return s.squash(source, passwd, remote)
}

func (s *Squash) squash(source *url.URL, passwd string, remote *string) (string, error) {
	value := source.String()
	value = fmt.Sprintf("%s:%s", value, passwd)

	record := s.Storage.SearchHashed(value)
	if record != nil && (record.Password == nil || *record.Password == passwd) {
		return fmt.Sprintf("%s/%s", s.BaseURL.String(), record.Hashed), nil
	}

	for n := s.MinSize; n <= s.MaxSize; n++ {
		squashed, err := s.SquashAlgo.Squash(value, n)
		if err != nil {
			log.Info().Err(err).Int("size", n).Msg("failed to squash the link")
			continue
		}

		record := types.New(source.String(), squashed, string(s.SquashAlgo))
		record.IP = remote
		if passwd != "" {
			record.Password = &passwd
		}
		log.Info().Str("record", record.String()).Msg("squashed the link")
		return fmt.Sprintf("%s/%s", s.BaseURL, squashed), s.Storage.Save(record)
	}

	return "", fmt.Errorf("failed to squash the link: %s", value)
}
