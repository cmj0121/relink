package server

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// The global interface to register the routes.
func (s *Server) RegisterRoutes(r *gin.Engine) {
	// register the route for the health check
	r.Any("/:squash", s.routeSolveSquash)
}

// Solve the squash link and redirect to the original link.
func (s *Server) routeSolveSquash(c *gin.Context) {
	// solve the squash link to get the original link
	link := "https://example.com"

	// use HTTP 307 to redirect to the original link to keep the original method
	c.Redirect(http.StatusTemporaryRedirect, link)
}
