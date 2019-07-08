fragment realworld

use {
	"std" 1.0
	"std/url" 1.0
}

UserResolver = resolver {
	user realworld::User

	# email resolves the user's email address
	email (EmailAddress or ErrUnauth) => authOwner(this.user, this.user.email)

	# username resolves the user's username
	username Username => this.user.username

	# bio resolves the user's biography if any
	bio ?Text => this.user.bio

	# image resolves the user's avatar image url
	image ?url::Url => this.user.image

	# following resolves all users the user is following
	following Set<UserResolver> =>
		map(this.user.following, (u) => UserResolver{user: u})

	# followers resolves all users following the user
	followers Set<UserResolver> =>
		map(this.user.followers, (u) => UserResolver{user: u})
	
	# publishedArticles resolves all articles published by the user
	publishedArticles Set<ArticleResolver> =>
		map(this.user.publishedArticles, (a) => ArticleResolver{article: a})
}
