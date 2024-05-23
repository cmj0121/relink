package algo

import (
	"fmt"
)

type SquashAlgo string

const (
	RAND SquashAlgo = "rand"
	HASH SquashAlgo = "hash"
)

var (
	// The possible letters to squash the link.
	LETTERS = []rune("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
)

func (a *SquashAlgo) Squash(src string, size int) (string, error) {
	switch *a {
	case RAND:
		return SquashByRand(src, size)
	case HASH:
		return SquashByHash(src, size)
	default:
		return "", fmt.Errorf("unsupported algorithm: %s", *a)
	}
}
