package server

import (
	"database/sql"
	"embed"
	"net/url"

	"github.com/gin-contrib/logger"
	"github.com/gin-gonic/gin"
	_ "github.com/mattn/go-sqlite3"
	"github.com/rs/zerolog/log"
)

type Connection struct {
	*sql.DB
}

func (c *Connection) UnmarshalText(text []byte) error {
	if c.DB != nil {
		c.DB.Close()
	}

	if len(text) == 0 {
		log.Info().Msg("no database connection")
		return nil
	}

	url, err := url.Parse(string(text))
	if err != nil {
		log.Warn().Err(err).Str("path", string(text)).Msg("failed to parse the URL")
		return err
	}

	driver, path := url.Scheme, url.Host
	db, err := sql.Open(driver, path)
	if err != nil {
		log.Warn().Err(err).Str("driver", driver).Str("path", path).Msg("failed to open the database")
		return err
	}

	if err := db.Ping(); err != nil {
		log.Warn().Err(err).Str("driver", driver).Str("path", path).Msg("failed to ping the database")
		return err
	}

	c.DB = db
	return nil
}

// The server instance to hold settings and run the RESTFul API server.
type Server struct {
	Bind      string      `short:"b" default:":8080" help:"The address to bind the server."`
	AuthToken *string     `help:"The token to authenticate the request."`
	Conn      *Connection `short:"d" default:"sqlite3://relink.sql" help:"The directory to store the data."`

	BaseURL *url.URL `short:"u" default:"https://401.tw" help:"The base URL to squash the link."`
	MinSize int      `short:"m" default:"4" help:"The minimum size of the squashed link."`
	MaxSize int      `short:"M" default:"8" help:"The maximum size of the squashed link."`

	limiter *RateLimiter
}

// Create a new instance of Server with the default settings.
func New() *Server {
	return &Server{
		Bind:    ":8080",
		limiter: NewLimiter(),
	}
}

// Run the RESTFul API server with the known settings.
func (s *Server) Run(view embed.FS) error {
	s.limiter = NewLimiter()

	// set as the release mode
	gin.SetMode(gin.ReleaseMode)

	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(logger.SetLogger())

	s.RegisterRoutes(r, view)
	log.Info().Str("bind", s.Bind).Msg("start the server ...")
	return r.Run(s.Bind)
}

// The authentication middleware to check the token.
func (s *Server) AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		token := c.GetHeader("Authorization")

		if s.AuthToken != nil {
			if !s.limiter.Check(c.ClientIP()) {
				log.Info().Str("ip", c.ClientIP()).Msg("the IP address is banned")
				c.AbortWithStatus(429)
			}

			if token == "" {
				c.AbortWithStatus(401)
			}

			if token != *s.AuthToken {
				s.limiter.Ban(c.ClientIP())
				c.AbortWithStatus(403)
			}
		}
	}
}
