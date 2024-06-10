package types

import (
	"context"
	"database/sql"
	"fmt"
	"os"
	"reflect"
	"testing"

	"github.com/go-faker/faker/v4"
	_ "github.com/mattn/go-sqlite3"
)

func NewDatabase(path string, t *testing.T) *sql.DB {
	uri := fmt.Sprintf("sqlite3://%s", path)

	migrate := Migrate{Database: uri}
	if err := migrate.Run(); err != nil {
		t.Fatalf("failed to migrate the database: %s", err)
	}

	db, err := sql.Open("sqlite3", path)
	if err != nil {
		t.Fatalf("failed to open the database: %s", err)
	}

	return db
}

func FakeRelink(t *testing.T) *Relink {
	relink := Relink{}
	err := faker.FakeData(&relink)
	if err != nil {
		t.Fatalf("failed to fake the data: %s", err)
	}

	return &relink
}

func TestAddRelink(t *testing.T) {
	db := "./add_relink_test.db"
	defer func() {
		os.Remove(db)
	}()

	relink := FakeRelink(t)
	database := NewDatabase(db, t)

	if err := relink.Insert(database); err != nil {
		t.Fatalf("failed to insert the record: %s", err)
	}

	record, err := Get(relink.Key, database)
	if err != nil {
		t.Fatalf("failed to get the record: %s", err)
	} else if record == nil {
		t.Errorf("failed to get the record")
	} else if reflect.DeepEqual(record, relink) {
		t.Errorf("the record is not equal to the original record")
	}
}

func TestDeleteRelink(t *testing.T) {
	db := "./delete_relink_test.db"
	defer func() {
		os.Remove(db)
	}()

	relink := FakeRelink(t)
	database := NewDatabase(db, t)

	if err := relink.Insert(database); err != nil {
		t.Fatalf("failed to insert the record: %s", err)
	} else if err := relink.Delete(database); err != nil {
		t.Fatalf("failed to delete the record: %s", err)
	}

	record, err := Get(relink.Key, database)
	if err != nil {
		t.Fatalf("failed to get the record: %s", err)
	} else if record == nil {
		t.Errorf("failed to get the record")
	} else if record.DeletedAt == nil {
		t.Errorf("the record is not deleted")
	} else if record.DeletedAt.IsZero() {
		t.Errorf("the record is not deleted")
	}
}

func TestIterRelinks(t *testing.T) {
	db := "./iter_relink_test.db"
	defer func() {
		os.Remove(db)
	}()

	database := NewDatabase(db, t)
	count := 64

	for idx := 0; idx < count; idx++ {
		relink := FakeRelink(t)
		if err := relink.Insert(database); err != nil {
			t.Fatalf("failed to insert the record: %s", err)
		}
	}

	relinks, err := IterRelink(context.Background(), database)
	if err != nil {
		t.Fatalf("failed to iterate the records: %s", err)
	}

	var total int
	for record := range relinks {
		if record == nil {
			t.Errorf("failed to iterate the record")
		}
		total++
	}

	if total != count {
		t.Errorf("the total is not equal to the count")
	}
}
