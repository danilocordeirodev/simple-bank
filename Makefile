DB_URL=postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable
POSTGRES_CONTAINER_NAME=postgres-simple-bank
POSTGRES_IMAGE=postgres:14-alpine

postgres:
	docker run --name $(POSTGRES_CONTAINER_NAME) -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d $(POSTGRES_IMAGE)

createdb:
	docker exec -it $(POSTGRES_CONTAINER_NAME) createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it $(POSTGRES_CONTAINER_NAME) dropdb simple_bank

migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose down

sqlc:
	sqlc generate

test:
	go test -v -cover ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/danilocordeirodev/simple-bank/db/sqlc Store

.PHONY: network postgres createdb dropdb migrateup migratedown sqlc test server mock