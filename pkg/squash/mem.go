package squash

import (
	"context"
	"sync"

	"github.com/cmj0121/relink/pkg/types"
	"github.com/rs/zerolog/log"
)

type Mem struct {
	mu sync.RWMutex

	sources map[string]*types.Record
	squashs map[string]*types.Record
}

func NewMem() (*Mem, error) {
	return &Mem{
		sources: make(map[string]*types.Record),
		squashs: make(map[string]*types.Record),
	}, nil
}

// save the key-value pair to the storage
func (m *Mem) Save(record *types.Record) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if r, ok := m.squashs[record.Hashed]; ok && r.Hashed != record.Hashed {
		log.Debug().Str("record", r.String()).Msg("value already exists")
		delete(m.sources, r.Hashed)
	}

	m.sources[record.Hashed] = record
	m.squashs[record.Source] = record

	return nil
}

func (m *Mem) SearchSource(key string) (string, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	record, ok := m.sources[key]
	return record.Source, ok
}

func (m *Mem) SearchHashed(key string) (string, bool) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	record, ok := m.squashs[key]
	return record.Hashed, ok
}

func (m *Mem) List(ctx context.Context) <-chan *types.Record {
	ch := make(chan *types.Record)

	go func() {
		m.mu.RLock()
		defer m.mu.RUnlock()
		defer close(ch)

		for _, record := range m.sources {
			select {
			case <-ctx.Done():
				return
			case ch <- record:
			}
		}
	}()

	return ch
}
