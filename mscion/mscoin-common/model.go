package common

type Bizcode int

const SuccessCode Bizcode = 0

type Result struct {
	Code    Bizcode `json:"code"`
	Message string  `json:"message"`
	Date    any     `json:"date"`
}

func NeResult() *Result {
	return &Result{}
}

func (r *Result) Fail(code Bizcode, meg string) {
	r.Code = code
	r.Message = meg
}

func (r *Result) Success(date any) {
	r.Code = SuccessCode
	r.Message = "success"
	r.Date = date
}

func (r *Result) Deal(date any, err error) *Result {
	if err != nil {
		r.Fail(-999, err.Error())
		return r
	}
	r.Success(date)
	return r
}
