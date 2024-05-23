package algo

// squash the link by the random string.
func SquashByHash(src string, size int) (string, error) {
	var buf = make([]rune, size)

	for idx, ch := range src {
		index := int(ch) + idx
		buf[idx%size] = LETTERS[index%len(LETTERS)]
	}

	return string(buf), nil
}
