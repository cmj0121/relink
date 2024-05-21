package relink

import (
	"os"

	"github.com/alecthomas/kong"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

// The main instance to hold the arguments and options, and to run the command.
type ReLink struct {
	// The verbose level of the command.
	Verbose int `short:"v" type:"counter" help:"Set the verbose level of the command."`
}

// Create a new instance of ReLink with the default settings.
func New() *ReLink {
	return &ReLink{}
}

// Parse the arguments and options from the command line, and run the command.
func (r *ReLink) ParseAndRun() error {
	kong.Parse(r)
	return r.Run()
}

// Run the command with the known arguments and options.
func (r *ReLink) Run() error {
	r.prologue()
	defer r.epilogue()

	return nil
}

// setup everything before running the command
func (r *ReLink) prologue() {
	// setup the logger
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})

	// set the verbose level
	switch r.Verbose {
	case 0:
		zerolog.SetGlobalLevel(zerolog.ErrorLevel)
	case 1:
		zerolog.SetGlobalLevel(zerolog.WarnLevel)
	case 2:
		zerolog.SetGlobalLevel(zerolog.InfoLevel)
	case 3:
		zerolog.SetGlobalLevel(zerolog.DebugLevel)
	default:
		zerolog.SetGlobalLevel(zerolog.TraceLevel)
	}

	log.Info().Msg("starting the relink ...")
}

// cleanup everything after running the command
func (r *ReLink) epilogue() {
	log.Info().Msg("finished the relink ...")
}
