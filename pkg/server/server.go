package server

import (
	"github.com/gin-contrib/logger"
	"github.com/gin-gonic/gin"
)

// The server instance to hold settings and run the RESTFul API server.
type Server struct {
	Bind string `short:"b" default:":8080" help:"The address to bind the server."`
}

// Create a new instance of Server with the default settings.
func New() *Server {
	return &Server{
		Bind: ":8080",
	}
}

// Run the RESTFul API server with the known settings.
func (s *Server) Run() error {
	// set as the release mode
	gin.SetMode(gin.ReleaseMode)

	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(logger.SetLogger())

	s.RegisterRoutes(r)
	return r.Run(s.Bind)
}
