package gapi

import (
	"fmt"

	db "github.com/danilocordeirodev/simple-bank/db/sqlc"
	"github.com/danilocordeirodev/simple-bank/pb"
	"github.com/danilocordeirodev/simple-bank/token"
	"github.com/danilocordeirodev/simple-bank/util"
)

type Server struct {
	pb.UnimplementedSimpleBankServer
	store      db.Store
	tokenMaker token.Maker
	config     util.Config
}

func NewServer(config util.Config, store db.Store) (*Server, error) {

	tokenMaker, err := token.NewPasetoMaker(config.TokenSymmetricKey)
	if err != nil {
		return nil, fmt.Errorf("cannot create token maker: %w", err)
	}

	server := &Server{store: store, tokenMaker: tokenMaker, config: config}

	return server, nil
}