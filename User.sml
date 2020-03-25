fragment realworld {
	"std" 1.0
	"std/url" 1.0
	"std/uuid" 1.0
}

UserId = uuid::Uuidv4

User = entity {
	id                UserId
	email             EmailAddress
	username          Username
	bio               ?String
	image             ?url::Url
	passwordHash      PasswordHash
	following         Set<User>
	followers         Set<User>
	publishedArticles Set<Article>
	publishedComments Set<Comment>
}
