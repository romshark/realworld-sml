fragment realworld

ErrUnauth = Nil
ErrWrongCredentials = Nil
ErrEmailReserved = Nil
ErrUsernameReserved = Nil
ErrFolloweeNotFound = Nil
ErrFolloweeInvalid = Nil
ErrArticleNotFound = Nil
ErrCommentNotFound = Nil
ErrTargetNotFound = Nil
ErrUserNotFound = Nil
ErrPasswordInvalid = struct {
	actual Uint32
	minLen Uint32
	maxLen Uint32
}