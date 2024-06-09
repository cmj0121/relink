package types

import (
	"context"
	"database/sql"
	"net/url"
	"time"

	"github.com/rs/zerolog/log"
)

type RelinkType string

const (
	RLink  RelinkType = "link"
	RText  RelinkType = "text"
	RImage RelinkType = "image"
)

// The relink table to store the original data and the shortened link.
type Relink struct {
	Key      string     `json:"key" faker:"uuid_hyphenated"`
	Type     RelinkType `json:"type" faker:"oneof:link,text,image"`
	Password *string    `json:"password" faker:"username"`
	PwdHint  *string    `json:"pwd_hint" faker:"sentence"`

	Link  *string `json:"link" faker:"url"`
	Text  *string `json:"text" faker:"sentence"`
	Image *string `json:"image" fake:"-"`
	Mime  *string `json:"mime" fake:"-"`

	// the timestamp mixed with the source
	CreatedAt time.Time  `json:"created_at"`
	DeletedAt *time.Time `json:"deleted_at" faker:"-"`
}

// Create a new instance of Relink with the default settings.
func RelinkFromRows(rows *sql.Rows) *Relink {
	var relink Relink

	var password sql.NullString
	var hint sql.NullString
	var link sql.NullString
	var text sql.NullString
	var image sql.NullString
	var mime sql.NullString
	var deletedAt sql.NullTime

	switch err := rows.Scan(&relink.Key, &relink.Type, &password, &hint, &link, &text, &image, &mime, &relink.CreatedAt, &deletedAt); err {
	case nil:
		relink.Password = &password.String
		relink.PwdHint = &hint.String
		relink.Link = &link.String
		relink.Text = &text.String
		relink.Image = &image.String
		relink.Mime = &mime.String
		relink.DeletedAt = &deletedAt.Time
		return &relink
	case sql.ErrNoRows:
		return nil
	default:
		log.Warn().Err(err).Msg("failed to scan the row")
		return nil
	}
}

// Create a new instance of Relink with the default settings.
func RelinkFromRow(rows *sql.Row) *Relink {
	var relink Relink

	var password sql.NullString
	var hint sql.NullString
	var link sql.NullString
	var text sql.NullString
	var image sql.NullString
	var mime sql.NullString
	var deletedAt sql.NullTime

	switch err := rows.Scan(&relink.Key, &relink.Type, &password, &hint, &link, &text, &image, &mime, &relink.CreatedAt, &deletedAt); err {
	case nil:
		relink.Password = &password.String
		relink.PwdHint = &hint.String
		relink.Link = &link.String
		relink.Text = &text.String
		relink.Image = &image.String
		relink.Mime = &mime.String
		relink.DeletedAt = &deletedAt.Time
		return &relink
	case sql.ErrNoRows:
		return nil
	default:
		log.Warn().Err(err).Msg("failed to scan the row")
		return nil
	}
}

// Get the relink from the database.
func Get(key string, db *sql.DB) (*Relink, error) {
	stmt := "SELECT key, type, password, pwd_hint, link, text, image, mime, created_at, deleted_at FROM relink WHERE key = ?"
	row := db.QueryRow(stmt, key)

	relink := RelinkFromRow(row)
	if relink == nil {
		log.Debug().Str("key", key).Msg("failed to find the relink")
		return nil, sql.ErrNoRows
	}

	return relink, nil
}

// Iterate the relink from the database.
func IterRelink(ctx context.Context, db *sql.DB) (<-chan *Relink, error) {
	ch := make(chan *Relink)

	stmt := "SELECT key, type, password, pwd_hint, link, text, image, mime, created_at, deleted_at FROM relink ORDER BY created_at DESC"
	rows, err := db.Query(stmt)
	if err != nil {
		log.Warn().Err(err).Msg("failed to query the relink")
		return nil, err
	}

	go func() {
		defer close(ch)
		defer rows.Close()

		for rows.Next() {
			relink := RelinkFromRows(rows)
			if relink == nil {
				log.Debug().Msg("skip the empty relink")
				continue
			}

			select {
			case <-ctx.Done():
				return
			case ch <- relink:
			}
		}
	}()

	return ch, nil
}

// Insert the relink into the database.
func (r *Relink) Insert(db *sql.DB) error {
	sql_stmt := "INSERT INTO relink (key, type, password, pwd_hint, link, text, image, mime, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
	_, err := db.Exec(sql_stmt, r.Key, r.Type, r.Password, r.PwdHint, r.Link, r.Text, r.Image, r.Mime, r.CreatedAt)
	if err != nil {
		log.Warn().Err(err).Msg("failed to save the key-value pair")
		return err
	}

	return nil
}

// Mark the relink as deleted.
func (r *Relink) Delete(db *sql.DB) error {
	sql_stmt := "UPDATE relink SET deleted_at = ? WHERE key = ?"
	_, err := db.Exec(sql_stmt, time.Now(), r.Key)
	if err != nil {
		log.Warn().Err(err).Msg("failed to delete the key-value pair")
		return err
	}

	return nil
}

// Load the relink from the database.
func (r *Relink) Load(db *sql.DB) bool {
	var row *sql.Row

	switch r.Type {
	case RLink:
		stmt := "SELECT key FROM relink WHERE type = ? AND password = ? AND link = ? AND deleted_at IS NULL"
		row = db.QueryRow(stmt, r.Type, r.Password, r.Link)
	case RText:
		stmt := "SELECT key FROM relink WHERE type = ? AND password = ? AND text = ? AND deleted_at IS NULL"
		row = db.QueryRow(stmt, r.Type, r.Password, r.Text)
	default:
		log.Debug().Str("type", string(r.Type)).Msg("unsupported type")
		return false
	}

	var key string
	switch err := row.Scan(&key); err {
	case sql.ErrNoRows:
		log.Debug().Msg("record not found")
		return false
	case nil:
		r.Key = key
		return true
	default:
		log.Warn().Err(err).Msg("failed to scan the row")
		return false
	}
}

// Check if the relink is valid.
func (r *Relink) IsValid() bool {
	switch r.Type {
	case RLink:
		if r.Link == nil || *r.Link == "" {
			return false
		}

		link, err := url.Parse(*r.Link)
		if err != nil || link.Scheme == "" {
			return false
		}

		return true
	case RText:
		return r.Text != nil && *r.Text != ""
	case RImage:
		return r.Image != nil && *r.Image != ""
	default:
		return false
	}
}
