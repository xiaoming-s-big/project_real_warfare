package logic

import (
	"context"
	"grpc-common/ucenter/types/register"
	"mscoin-common/tools"
	"ucenter/internal/svc"

	"github.com/zeromicro/go-zero/core/logx"
)

type RegisterLogic struct {
	ctx    context.Context
	svcCtx *svc.ServiceContext
	logx.Logger
}

func NewRegisterByPhoneLogic(ctx context.Context, svcCtx *svc.ServiceContext) *RegisterLogic {
	return &RegisterLogic{
		ctx:    ctx,
		svcCtx: svcCtx,
		Logger: logx.WithContext(ctx),
	}
}

func (l *RegisterLogic) RegisterByPhone(in *register.RegReq) (*register.RegRes, error) {
	// todo: add your logic here and delete this line
	logx.Info("ucenter rpc register by phone call....")
	return &register.RegRes{}, nil
}

func (l *RegisterLogic) SendCode(req *register.CodeReq) (*register.NoRes, error) {
	//* 收到手机号和国家标识
	//* 生成验证码
	//* 根据对应的国家和手机号调用对应的短信平台发送验证码
	//* 将验证码存入redis，过期时间5分钟
	//* 返回成功
	code := tools.Rand4Num()
}
