package algo

import (
	"fmt"
)

type SquashAlgo string

const (
	RAND SquashAlgo = "rand"
)

func (a *SquashAlgo) Squash(src string, size int) (string, error) {
	switch *a {
	case RAND:
		return SquashByRand(src, size)
	default:
		return "", fmt.Errorf("unsupported algorithm: %s", *a)
	}
}
