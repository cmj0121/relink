package main

import (
	"github.com/cmj0121/relink"
	"github.com/rs/zerolog/log"
)

func main() {
	agent := relink.New()
	if err := agent.ParseAndRun(); err != nil {
		log.Fatal().Err(err).Msg("failed to run the command")
	}
}
