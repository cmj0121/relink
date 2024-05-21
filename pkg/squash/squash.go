package squash

import (
	"fmt"
	"math/rand"
	"net/url"

	"github.com/rs/zerolog/log"
)

const (
	// The default base URL to squash the link.
	DEFAULT_BASE_URL = "https://401.tw"
)

// The instance to squash the link and make it shorter.
type Squash struct {
	BaseURL *url.URL `short:"u" default:"https://401.tw" help:"The base URL to squash the link."`
	MaxSize int      `short:"s" default:"8" help:"The maximum size of the squashed link."`

	Source string `arg:"" optional:"" help:"The source of the link."`
}

// Create a new instance of Squash with the default settings.
func New() *Squash {
	baseURL, _ := url.Parse(DEFAULT_BASE_URL)

	return &Squash{
		BaseURL: baseURL,
		MaxSize: 8,
	}
}

// Parse the arguments and options from the command line, and run the command.
func (s *Squash) Run() error {
	log.Info().Str("source", s.Source).Msg("squash the link")
	squashed, err := s.Squash(s.Source)
	if err != nil {
		return err
	}

	log.Info().Str("source", s.Source).Str("squashed", squashed).Msg("squashed the link")
	fmt.Println(squashed)
	return nil
}

// Squash the link and make it shorter.
func (s *Squash) Squash(link string) (string, error) {
	source, err := url.Parse(link)
	if err != nil {
		log.Warn().Err(err).Str("link", link).Msg("failed to parse the link")
		return "", err
	}

	return s.squash(source), nil
}

func (s *Squash) squash(source *url.URL) string {
	var letters = []rune("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
	var buf = make([]rune, s.MaxSize)

	for i := 0; i < s.MaxSize; i++ {
		buf[i] = letters[rand.Intn(len(letters))]
	}

	return fmt.Sprintf("%s/%s", s.BaseURL.String(), string(buf))
}
