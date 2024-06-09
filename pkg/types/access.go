package types

import (
	"context"
	"database/sql"
	"time"

	"github.com/rs/zerolog/log"
)

type AccessLog struct {
	Key       string `json:"key"`
	IP        string `json:"ip"`
	UserAgent string `json:"user_agent"`

	// the timestamp mixed with the source
	CreatedAt time.Time `json:"created_at"`
}

// Create a new instance of AccessLog from the query row.
func AccessLogFromRows(rows *sql.Rows) *AccessLog {
	var access_log AccessLog

	switch err := rows.Scan(&access_log.Key, &access_log.IP, &access_log.UserAgent, &access_log.CreatedAt); err {
	case nil:
		return &access_log
	case sql.ErrNoRows:
		return nil
	default:
		log.Warn().Err(err).Msg("failed to scan the row")
		return nil
	}
}

// Iterate the access log from the database.
func IterAccessLog(ctx context.Context, db *sql.DB, hashed string) (chan<- *AccessLog, error) {
	ch := make(chan *AccessLog)

	stmt := "SELECT key, ip, user_agent, created_at FROM access_log WHERE hashed = ?"
	rows, err := db.Query(stmt, hashed)
	if err != nil {
		log.Warn().Err(err).Str("hashed", hashed).Msg("failed to query the access log")
		return nil, err
	}

	go func() {
		defer close(ch)
		defer rows.Close()

		for rows.Next() {
			access_log := AccessLogFromRows(rows)
			if access_log == nil {
				log.Debug().Msg("skip the empty log")
				continue
			}

			select {
			case <-ctx.Done():
				return
			case ch <- access_log:
			}
		}

	}()

	return ch, nil
}
