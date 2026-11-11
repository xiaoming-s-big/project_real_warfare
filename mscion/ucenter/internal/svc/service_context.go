package svc

import (
	"ucenter/internal/config"

	"github.com/zeromicro/go-zero/core/stores/cache"
)

type ServiceContext struct {
	Config config.Config
	Cache  cache.Cache
}

func NewServiceContext(c config.Config) *ServiceContext {
	redisCache := cache.New(c.CacheRedis,
						nil,
								cache.NewStat("mscoin"),
					nil,
								func(o *cache.Options){})

	return &ServiceContext{
		Config: c,
		Cache:  redisCache,
	}
}
