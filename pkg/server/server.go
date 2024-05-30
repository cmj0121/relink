package server

import (
	"embed"

	"github.com/cmj0121/relink/pkg/squash"
	"github.com/gin-contrib/logger"
	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog/log"
)

// The server instance to hold settings and run the RESTFul API server.
type Server struct {
	Bind      string  `short:"b" default:":8080" help:"The address to bind the server."`
	AuthToken *string `help:"The token to authenticate the request."`

	limiter *RateLimiter
	squash.Squash
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
