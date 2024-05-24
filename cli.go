package relink

import (
	"embed"
	"fmt"
	"os"

	"github.com/alecthomas/kong"
	"github.com/cmj0121/relink/pkg/server"
	"github.com/cmj0121/relink/pkg/squash"
	"github.com/cmj0121/relink/pkg/types"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

//go:embed web/build/web/*
var view embed.FS

type SubCommand struct {
	Server  server.Server `cmd:"" help:"Run the RESTFul API server."`
	Squash  squash.Squash `cmd:"" help:"Squash the link and make it shorter."`
	Migrate types.Migrate `cmd:"" help:"Migrate the storage."`
}

// The main instance to hold the arguments and options, and to run the command.
type ReLink struct {
	// The verbose level of the command.
	Verbose int `short:"v" type:"counter" help:"Set the verbose level of the command."`

	// The sub-command to run.
	SubCommand `cmd:"" help:"The sub-command to run."`
}

// Create a new instance of ReLink with the default settings.
func New() *ReLink {
	return &ReLink{}
}

// Parse the arguments and options from the command line, and run the command.
func (r *ReLink) ParseAndRun() error {
	ctx := kong.Parse(r)
	return r.Run(ctx)
}

// Run the command with the known arguments and options.
func (r *ReLink) Run(ctx *kong.Context) error {
	r.prologue()
	defer r.epilogue()

	switch subcmd := ctx.Command(); subcmd {
	case "server":
		return r.Server.Run(view)
	case "squash <source>":
		return r.Squash.Run()
	case "migrate <database>":
		return r.Migrate.Run()
	default:
		log.Warn().Str("command", subcmd).Msg("not implemented sub-command")
		return fmt.Errorf("not implemented sub-command: %s", subcmd)
	}
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
