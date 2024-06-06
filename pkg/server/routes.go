package server

import (
	"embed"
	"fmt"
	"io/fs"
	"net/http"

	"github.com/cmj0121/relink/pkg/types"
	"github.com/gin-gonic/gin"
)

var (
	fileHandler http.Handler
)

// The global interface to register the routes.
func (s *Server) RegisterRoutes(r *gin.Engine, view embed.FS) {
	fs, _ := fs.Sub(view, "web/build/web")
	fileHandler = http.FileServer(http.FS(fs))

	// register the route for the health check
	r.Any("/:squash", s.routeSolveSquash)
	r.POST("/api/squash", s.routeGenerateSquash)

	auth := r.Group("/")
	{
		auth.Use(s.AuthMiddleware())
		auth.GET("/api/squash", s.routeListSquash)
	}

	// serve the static files
	r.NoRoute(s.routeStatic)
}

// Solve the squash link and redirect to the original link.
func (s *Server) routeSolveSquash(c *gin.Context) {
	// solve the squash link to get the original link
	squashed := c.Param("squash")
	record := s.Squash.Storage.SearchSource(squashed)

	if record == nil {
		s.routeStatic(c)
	} else if record.Password == nil || c.Query("password") == *record.Password {
		// use HTTP 307 to redirect to the original link to keep the original method
		c.Redirect(http.StatusTemporaryRedirect, record.Source)
	} else {
		link := fmt.Sprintf("/#/need-password-%v", squashed)
		c.Redirect(http.StatusTemporaryRedirect, link)
	}
}

// Generate the squash link and return the squashed link.
func (s *Server) routeGenerateSquash(c *gin.Context) {
	src := c.Query("src")
	if src == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing src"})
		return
	}

	// the remote IP address
	remote := c.ClientIP()

	// generate the squashed link
	passwd := c.Query("password")
	squashed, err := s.Squash.SquashToLink(src, passwd, &remote)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, squashed)
}

// List all the squashed links.
func (s *Server) routeListSquash(c *gin.Context) {
	records := []*types.Record{}

	for record := range s.Squash.Storage.List(c) {
		switch record {
		case nil:
			continue
		default:
			records = append(records, record)
		}
	}

	c.JSON(http.StatusOK, records)
}

// Serve the static web UI
func (s *Server) routeStatic(c *gin.Context) {
	fileHandler.ServeHTTP(c.Writer, c.Request)
}
