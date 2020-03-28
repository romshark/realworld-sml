fragment realworld {
	"std" 1.0
}

GraphRoot = resolver {
	# user resolves a user by the given username
	user (username Username) -> ?UserResolver => {
		user = entity<User>(predicate: (u) => u.username == username)
		& = user as u {
			User then UserResolver{user: u}
		}
	}

	# article resolves an article by the given id
	article (slug String) -> ?ArticleResolver => {
		article = entity<Article>(predicate: (a) => a.id == slug)
		& = article as a {
			Article then ArticleResolver{article: a}
		}
	}

	# comment resolves an comment by the given id
	comment (commentId CommentId) -> ?CommentResolver => {
		comment = entity<Comment>(predicate: (a) => a.id == commentId)
		& = comment as a {
			Comment then CommentResolver{comment: a}
		}
	}

	# articleBy resolves many articles by the given search criteria
	articleBy (
		tags ?Set<Tag>,
		authors ?Set<Username>,
	) -> Array<ArticleResolver> => {
		matchByTags = (a Article) -> Bool => tags as tags {
			Set<Tag> then any(tags, (tag) => tag in a.tags)
			else false
		}

		matchByAuthors = (a Article) -> Bool => authors as authors {
			Set<Username> then any(
				authors,
				(authorUsername) => a.author.username == authorUsername,
			)
			else false
		}

		articles = entities<Article>(
			predicate: (a) => matchByTags(a) or matchByAuthors(a),
		)
		& = map(articles, (a) => ArticleResolver{article: a})
	}

	# feed resolves the articles feed for a particular user identified by
	# the given username
	feed (username Username) -> (
		Array<ArticleResolver> or
		ErrUserNotFound or
		ErrUnauth
	) => {
		user = entity<User>(predicate: (u) => u.username == username)

		& = {
			// Ensure the user exists
			user == Nil then ErrUserNotFound

			// Ensure the client is the user for which the feed for requested
			!isOwner(owner: User from user) then ErrUnauth

			else {
				feedArticles = map(
					(User from user).following,
					(followee) => followee.publishedArticles,
				)
				sorted = std::sortBy(feedArticles, std::Order{
					by:    Article.createdAt,
					order: std::desc,
				})
				& = map(sorted, (a) => ArticleResolver{article: a})
			}
		}
	}

	registration
	authentication
	userUpdate

	newFollower
	canceledFollowership

	articlePublication
	articleDeletion
	articleUpdate

	commentPublication
	commentDeletion
}
