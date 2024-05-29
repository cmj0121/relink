package server

import (
	"embed"

	"github.com/cmj0121/relink/pkg/squash"
	"github.com/gin-contrib/logger"
	"github.com/gin-gonic/gin"
)

// The server instance to hold settings and run the RESTFul API server.
type Server struct {
	Bind      string  `short:"b" default:":8080" help:"The address to bind the server."`
	AuthToken *string `help:"The token to authenticate the request."`

	squash.Squash
}

// Create a new instance of Server with the default settings.
func New() *Server {
	return &Server{
		Bind:   ":8080",
		Squash: *squash.New(),
	}
}

// Run the RESTFul API server with the known settings.
func (s *Server) Run(view embed.FS) error {
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
			if token == "" {
				c.AbortWithStatus(401)
			}

			if token != *s.AuthToken {
				c.AbortWithStatus(403)
			}
		}
	}
}
