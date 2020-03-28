fragment realworld {
	"std" 1.0
	"std/time" 1.0
}

# commentPublication is analogous to "POST /api/articles/:slug/comments"
# resolving a mutation causing the creation of a new t:Comment entity
# on a t:Article identified by p:slug in case of success
commentPublication = (
	slug ArticleSlug,
	authorUsername Username,
	body CommentBody,
) -> (
	std::Mutation<CommentResolver> or
	ErrUnauth or
	ErrUserNotFound or
	ErrArticleNotFound
) => {
	author = entity<User>(predicate: (u) => u.username == authorUsername)
	article = entity<Article>(predicate: (a) => a.slug == slug)

	& = match {
		// Ensure the author exists
		author == Nil then ErrUserNotFound

		// Ensure the article exists
		article != Article then ErrArticleNotFound

		// Ensure users cant publish posts on behalf of other users
		!isOwner(owner: User from author) then ErrUnauth

		else {
			author = User from author
			article = Article from article

			newComment = Comment{
				id: {
					slug:  article.slug,
					index: article.comments[len(article.comments) - 1] as i {
						Uint64 then i + 1
						else 0
					},
				},
				author:    author,
				target:    target,
				body:      body,
				createdAt: time::now(),
			}

			updatedAuthorProfile = User{
				publishedComments: {
					..author.publishedComments,
					newComment,
				},
				..author,
			}

			& = std::Mutation{
				effects: {
					// Update the author profile
					std::mutated(author, updatedAuthorProfile),

					// Create a new comment entity
					std::new(newComment),
				},
				data: CommentResolver{comment: newComment},
			}
		}
	}
}
