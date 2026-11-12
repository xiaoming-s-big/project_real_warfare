// Code scaffolded by goctl. Safe to edit.
// goctl 1.10.2

package logic

import (
	"context"
	"grpc-common/ucenter/types/register"
	"time"
	"ucenter-api/internal/svc"
	"ucenter-api/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type RegisterLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewRegisterLogic(ctx context.Context, svcCtx *svc.ServiceContext) *RegisterLogic {
	return &RegisterLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *RegisterLogic) Register(req *types.Request) (resp *types.Response, err error) {
	// todo: add your logic here and delete this line
	ctx, cancelFunc := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancelFunc()
	_, err = l.svcCtx.UCRegisterRpc.RegisterByPhone(ctx, &register.RegReq{})
	if err != nil {
		return nil, err
	}
	logx.Info("api register")
	return

}

func (l *RegisterLogic) SendCode(req *types.CodeRequest) (resp *types.Response, err error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	_, err = l.svcCtx.UCRegisterRpc.SendCode(ctx, &register.CodeReq{
		Phone:   req.Phone,
		Country: req.Country,
	})
	if err != nil {
		return nil, err
	}
	return
}
