fragment realworld

use {
	"std" 1.0
	"std/url" 1.0
}

User = entity {
	email             EmailAddress
	username          Username
	bio               ?Text
	image             ?url::Url
	passwordHash      PasswordHash
	following         Set<User>
	followers         Set<User>
	publishedArticles Set<Article>
	publishedComments Set<Comment>
}
