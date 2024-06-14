package types

import (
	"context"
	"database/sql"
	"time"

	"github.com/rs/zerolog/log"
)

type AccessLog struct {
	Code      string `json:"code"`
	IP        string `json:"ip"`
	UserAgent string `json:"user_agent"`

	// the timestamp mixed with the source
	CreatedAt time.Time `json:"created_at"`
}

type StatByGroup struct {
	Count int    `json:"count"`
	Range string `json:"range"`
}

type Statistics struct {
	Code string `json:"code"`

	Total int           `json:"total"`
	Chart []StatByGroup `json:"chart"`
}

// Create a new instance of AccessLog from the query row.
func AccessLogFromRows(rows *sql.Rows) *AccessLog {
	var access_log AccessLog

	switch err := rows.Scan(&access_log.Code, &access_log.IP, &access_log.UserAgent, &access_log.CreatedAt); err {
	case nil:
		return &access_log
	case sql.ErrNoRows:
		return nil
	default:
		log.Warn().Err(err).Msg("failed to scan the row")
		return nil
	}
}

func (s *Statistics) Analysis(ctx context.Context, db *sql.DB) error {
	if err := s.GetTotal(ctx, db); err != nil {
		return err
	} else if err := s.GetChart(ctx, db); err != nil {
		return err
	}

	return nil
}

func (s *Statistics) GetTotal(ctx context.Context, db *sql.DB) error {
	stmt := `SELECT COUNT(*) FROM relink_access_log WHERE key = ?`
	row := db.QueryRowContext(ctx, stmt, s.Code)

	if err := row.Scan(&s.Total); err != nil {
		log.Warn().Err(err).Str("key", s.Code).Msg("failed to scan the access log")
		return err
	}

	return nil
}

func (s *Statistics) GetChart(ctx context.Context, db *sql.DB) error {
	stmt := `
		SELECT DATE(created_at) AS date, COUNT(*) AS count
		FROM relink_access_log
		WHERE key = ?
		GROUP BY date
	`

	rows, err := db.QueryContext(ctx, stmt, s.Code)
	if err != nil {
		log.Warn().Err(err).Str("key", s.Code).Msg("failed to get the access log")
		return err
	}

	defer rows.Close()
	for rows.Next() {
		var stat StatByGroup
		if err := rows.Scan(&stat.Range, &stat.Count); err != nil {
			log.Warn().Err(err).Str("key", s.Code).Msg("failed to scan the access log")
			return err
		}

		s.Chart = append(s.Chart, stat)
	}

	return nil
}

// Insert the access log into the database.
func (a *AccessLog) Insert(db *sql.DB) error {
	sql_stmt := "INSERT INTO relink_access_log (key, ip, user_agent, created_at) VALUES (?, ?, ?, ?)"
	_, err := db.Exec(sql_stmt, a.Code, a.IP, a.UserAgent, a.CreatedAt)
	if err != nil {
		log.Warn().Err(err).Msg("failed to save the access log")
		return err
	}

	return nil
}
