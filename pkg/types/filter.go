package types

import (
	"strings"

	"github.com/gin-gonic/gin"
)

type IterFilter struct {
	Image   bool
	Link    bool
	Text    bool
	Deleted bool
}

func NewIterFilter(ctx *gin.Context) *IterFilter {
	filter := &IterFilter{
		Image:   true,
		Link:    true,
		Text:    true,
		Deleted: true,
	}

	if ctx != nil {
		filter.FromGinContext(ctx)
	}

	return filter
}

func (f *IterFilter) FromGinContext(ctx *gin.Context) {
	f.Image = ctx.Query("image") == "1"
	f.Link = ctx.Query("link") == "1"
	f.Text = ctx.Query("text") == "1"
	f.Deleted = ctx.Query("deleted") == "1"
}

func (f *IterFilter) Merge(filters ...*IterFilter) {
	for _, filter := range filters {
		f.Image = f.Image && filter.Image
		f.Link = f.Link && filter.Link
		f.Text = f.Text && filter.Text
		f.Deleted = f.Deleted && filter.Deleted
	}
}

func (f *IterFilter) Types() string {
	types := []string{}
	if f.Image {
		types = append(types, "'image'")
	}
	if f.Link {
		types = append(types, "'link'")
	}
	if f.Text {
		types = append(types, "'text'")
	}

	return strings.Join(types, ", ")
}

func (f *IterFilter) ShouldDeleted() string {
	if f.Deleted {
		return "NOT"
	}

	return ""
}
