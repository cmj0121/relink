package algo

import (
	"math/rand"
)

// squash the link by the random string.
func SquashByRand(src string, size int) (string, error) {
	var buf = make([]rune, size)

	for i := 0; i < size; i++ {
		buf[i] = LETTERS[rand.Intn(len(LETTERS))]
	}

	return string(buf), nil
}
