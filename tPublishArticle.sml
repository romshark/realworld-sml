fragment realworld {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
}

EvArticlePublished = event {
	article Article

	article ArticleResolver => ArticleResolver{article: this.article}
}

# tPublishArticle is analogous to "POST /api/profiles/:username/follow"
tPublishArticle = (
	authorUsername Username,
	title ArticleTitle,
	description ArticleDescription,
	body ArticleBody,
	tags Set<Tag>,
) -> (
	std::Transaction<ArticleResolver> or
	ErrUnauth or
	ErrUserNotFound
) => {
	author = entity<realworld::User>(
		predicate: (u) => u.username == authorUsername,
	)

	& = match {
		// Ensure the author exists
		author == Nil then ErrUserNotFound{}

		// Ensure users cant publish posts on behalf of other users
		!isOwner(owner: realworld::User from author) then ErrUnauth{}

		else {
			author = realworld::User from author

			newArticle = Article {
				id:          uuid::v4(),
				title:       title,
				description: description,
				body:        body,
				tags:        tags,
				createdAt:   time::now(),
				author:      author,
				comments:    [],
			}

			updatedAuthorProfile = realworld::User{
				publishedArticles: std::setInsert(
					author.publishedArticles,
					newArticle,
				),
				..follower
			}

			& = std::Transaction<ArticleResolver>{
				effects: [
					// Update the author profile
					std::mutate(author, (u) => updatedAuthorProfile),

					// Create a new article entity
					std::new(newArticle),

					// Notify all followers about a new article being published
					std::event(author.followers, EvArticlePublished{
						article: newArticle,
					}),
				],
				data: ArticleResolver{article: newArticle},
			}
		}
	}
}
