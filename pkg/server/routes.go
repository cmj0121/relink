package server

import (
	"embed"
	"fmt"
	"io/fs"
	"math/rand"
	"net/http"
	"time"

	"github.com/cmj0121/relink/pkg/types"
	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog/log"
)

var (
	fileHandler http.Handler
	letters     = []rune("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
)

type RelinkBody struct {
	Type string `json:"type"`

	Password *string `json:"password"`
	PwdHint  *string `json:"pwd_hint"`
	Link     *string `json:"link"`
	Text     *string `json:"text"`
}

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
	squash := c.Param("squash")

	relink, err := types.Get(squash, s.Conn.DB)
	if err != nil || relink == nil {
		s.routeStatic(c)
		return
	}

	if relink.Password != nil && c.Query("password") != *relink.Password {
		switch relink.PwdHint {
		case nil:
			link := fmt.Sprintf("/#/need-password-%v", squash)
			c.Redirect(http.StatusTemporaryRedirect, link)
		default:
			link := fmt.Sprintf("/?hint=%v&#/need-password-%v", *relink.PwdHint, squash)
			c.Redirect(http.StatusTemporaryRedirect, link)
		}
		return
	}

	switch {
	case relink.Type == types.RLink && relink.Link != nil:
		// use HTTP 307 to redirect to the original link to keep the original method
		c.Redirect(http.StatusTemporaryRedirect, *relink.Link)
	case relink.Type == types.RText && relink.Text != nil:
		// show the raw plain text
		c.String(http.StatusOK, *relink.Text)
	default:
		// treat as the unauthorized request
		link := fmt.Sprintf("/#/need-password-%v", squash)
		c.Redirect(http.StatusTemporaryRedirect, link)
		return
	}
}

// Generate the squash link and return the squashed link.
func (s *Server) routeGenerateSquash(c *gin.Context) {
	paylod := &RelinkBody{}

	if err := c.BindJSON(&paylod); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	relink := types.Relink{
		Type:      types.RelinkType(paylod.Type),
		Password:  paylod.Password,
		PwdHint:   paylod.PwdHint,
		Link:      paylod.Link,
		Text:      paylod.Text,
		CreatedAt: time.Now(),
	}
	if !relink.IsValid() {
		c.JSON(http.StatusBadRequest, nil)
		return
	}

	if relink.Load(s.Conn.DB) && relink.DeletedAt == nil {
		// the record is already exist
		link := fmt.Sprintf("%v/%v", s.BaseURL, relink.Key)
		c.JSON(http.StatusCreated, link)
		return
	}

	for size := s.MinSize; size <= s.MaxSize; size++ {
		relink.Key = s.randomString(size)

		log.Debug().Interface("relink", relink).Msg("try to save the record")
		if err := relink.Insert(s.Conn.DB); err != nil {
			log.Info().Err(err).Msg("failed to save the record")
			continue
		}

		link := fmt.Sprintf("%v/%v", s.BaseURL, relink.Key)
		c.JSON(http.StatusCreated, link)
		return
	}

	c.JSON(http.StatusInternalServerError, nil)
}

// List all the squashed links.
func (s *Server) routeListSquash(c *gin.Context) {
	records := []*types.Relink{}

	iter, err := types.IterRelink(c, s.Conn.DB)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	for r := range iter {
		if r != nil {
			records = append(records, r)
		}
	}

	c.JSON(http.StatusOK, records)
}

// Serve the static web UI
func (s *Server) routeStatic(c *gin.Context) {
	fileHandler.ServeHTTP(c.Writer, c.Request)
}

// Generate a random string with the given length.
func (s *Server) randomString(n int) string {
	b := make([]rune, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}
