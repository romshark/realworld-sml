fragment realworld {
	"std" 1.0
	"std/url" 1.0
}

realworld::User = entity {
	email             EmailAddress
	username          Username
	bio               ?Text
	image             ?url::Url
	passwordHash      PasswordHash
	following         Set<realworld::User>
	followers         Set<realworld::User>
	publishedArticles Set<Article>
	publishedComments Set<Comment>
}
