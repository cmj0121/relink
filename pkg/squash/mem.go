package squash

import (
	"sync"

	"github.com/rs/zerolog/log"
)

type Mem struct {
	mu sync.RWMutex

	mem map[string]string
	rev map[string]string
}

func NewMem() (*Mem, error) {
	return &Mem{
		mem: make(map[string]string),
		rev: make(map[string]string),
	}, nil
}

// save the key-value pair to the storage
func (m *Mem) Save(key, value string) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if rev_key, ok := m.rev[value]; ok && rev_key != key {
		log.Debug().Str("key", key).Str("value", value).Str("rev_key", rev_key).Msg("value already exists")
		delete(m.mem, rev_key)
	}

	m.mem[key] = value
	m.rev[value] = key

	return nil
}

func (m *Mem) SearchValue(key string) (string, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	value, ok := m.mem[key]
	return value, ok
}

func (m *Mem) SearchKey(value string) (string, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	key, ok := m.rev[value]
	return key, ok
}
