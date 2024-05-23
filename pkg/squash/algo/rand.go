package algo

import (
	"math/rand"
)

// squash the link by the random string.
func SquashByRand(src string, size int) (string, error) {
	var letters = []rune("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
	var buf = make([]rune, size)

	for i := 0; i < size; i++ {
		buf[i] = letters[rand.Intn(len(letters))]
	}

	return string(buf), nil
}
