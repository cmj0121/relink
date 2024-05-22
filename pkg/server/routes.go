package server

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// The global interface to register the routes.
func (s *Server) RegisterRoutes(r *gin.Engine) {
	// register the route for the health check
	r.Any("/:squash", s.routeSolveSquash)
	r.POST("/api/squash", s.routeGenerateSquash)
}

// Solve the squash link and redirect to the original link.
func (s *Server) routeSolveSquash(c *gin.Context) {
	// solve the squash link to get the original link
	squashed := c.Param("squash")
	link, ok := s.Squash.Storage.SearchValue(squashed)

	if !ok || link == "" {
		c.AbortWithStatus(http.StatusNotFound)
	} else {
		// use HTTP 307 to redirect to the original link to keep the original method
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

	// generate the squashed link
	squashed, err := s.Squash.Squash(src)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, squashed)
}
