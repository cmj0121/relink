package squash

import (
	"fmt"
	"os"
	"testing"

	"github.com/cmj0121/relink/pkg/types"
)

var (
	record = types.New("source", "squashed", "algo")
)

func TestStorage(t *testing.T) {
	storages := []string{
		"memory://",
		"sqlite3://.test.sql",
	}

	defer func() {
		os.Remove(".test.sql")
	}()

	for _, target := range storages {
		storager := NewStorage()
		err := storager.UnmarshalText([]byte(target))
		if err != nil {
			t.Errorf("failed to unmarshal the storage: %s", err)
			continue
		}

		t.Run(fmt.Sprintf("test %v", target), testStorage(storager))
	}
}

func testStorage(storage Storager) func(t *testing.T) {
	return func(t *testing.T) {
		testStorageSave(storage, t)
		testStorageSearch(storage, t)
	}
}

func testStorageSave(storage Storager, t *testing.T) {
	err := storage.Save(record)
	if err != nil {
		t.Errorf("failed to save the key-value pair: %s", err)
	}
}

func testStorageSearch(storage Storager, t *testing.T) {
	key := record.Hashed
	value := record.Source

	_value, ok := storage.SearchSource(key)
	if !ok {
		t.Errorf("failed to search the value by the key")
	}

	if _value != value {
		t.Errorf("the value is not equal to the original value")
	}

	_key, ok := storage.SearchHashed(value)
	if !ok {
		t.Errorf("failed to search the key by the value")
	}

	if _key != key {
		t.Errorf("the key is not equal to the original key")
	}
}
