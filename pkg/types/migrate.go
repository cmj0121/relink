package types

import (
	"embed"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/source/iofs"
	"github.com/rs/zerolog/log"

	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/database/sqlite3"
)

//go:embed migrations/*.sql
var fd embed.FS

type Migrate struct {
	Database string `arg:"" description:"the database to migrate"`
}

func (m *Migrate) Run() error {
	dir, err := iofs.New(fd, "migrations")
	if err != nil {
		log.Warn().Err(err).Msg("failed to create the migration source")
		return err
	}

	actor, err := migrate.NewWithSourceInstance("iofs", dir, m.Database)
	if err != nil {
		log.Warn().Err(err).Msg("failed to create the migration instance")
		return err
	}

	return actor.Up()
}
