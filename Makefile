DB_URL=postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable
POSTGRES_CONTAINER_NAME=postgres-simple-bank
POSTGRES_IMAGE=postgres:14-alpine

network:
	docker network create bank-network

postgres:
	docker run --name $(POSTGRES_CONTAINER_NAME) -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d $(POSTGRES_IMAGE)

createdb:
	docker exec -it $(POSTGRES_CONTAINER_NAME) createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it $(POSTGRES_CONTAINER_NAME) dropdb simple_bank

migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migrateup1:
	migrate -path db/migration -database "$(DB_URL)" -verbose up 1

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose down

migratedown1:
	migrate -path db/migration -database "$(DB_URL)" -verbose down 1

new_migration:
	migrate create -ext sql -dir db/migration -seq $(name)

db_docs:
	dbdocs build doc/db.dbml

db_schema:
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

sqlc:
	sqlc generate

test:
	go test -v -cover ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/danilocordeirodev/simple-bank/db/sqlc Store
	mockgen -package mockwk -destination worker/mock/distributor.go github.com/danilocordeirodev/simple-bank/worker TaskDistributor

proto:
	rm -f pb/*.go
	rm -f doc/swagger/*.swagger.json
	protoc --proto_path=proto --go_out=pb --go_opt=paths=source_relative \
	--go-grpc_out=pb --go-grpc_opt=paths=source_relative \
	--grpc-gateway_out=pb --grpc-gateway_opt=paths=source_relative \
	--openapiv2_out=doc/swagger --openapiv2_opt=allow_merge=true,merge_file_name=simple_bank \
	proto/*.proto
	statik -src=./doc/swagger -dest=./doc

redis:
	docker run --name redis -p 6379:6379 -d redis:7-alpine

.PHONY: network postgres createdb dropdb migrateup migratedown sqlc test server mock migratedown1 migrateup1 new_migration db_docs db_schema proto redis