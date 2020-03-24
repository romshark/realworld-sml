fragment realworld {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
}

EvCommentPublished = event {
	comment Comment

	comment CommentResolver => CommentResolver{comment: this.comment}
}

# tPublishComment is analogous to "POST /api/articles/:slug/comments"
tPublishComment = (
	targetId uuid::UuidV4,
	authorUsername Username,
	body CommentBody,
) -> (
	std::Transaction<CommentResolver> or
	ErrUnauth or
	ErrUserNotFound or
	ErrTargetNotFound
) => {
	author = entity<realworld::User>(
		predicate: (u) => u.username == authorUsername,
	)
	articleById = entity<Article>(predicate: (a) => a.id == targetId)
	commentById = entity<Comment>(predicate: (c) => c.id == targetId)
	target = match {
		articleById == Article then Article from articleById
		commentById == Comment then Comment from commentById
	}

	& = match {
		// Ensure the author exists
		author == Nil then ErrUserNotFound

		// Ensure the target exists
		target == Nil then ErrTargetNotFound

		// Ensure users cant publish posts on behalf of other users
		!isOwner(owner: realworld::User from author) then ErrUnauth

		else {
			author = realworld::User from author
			target = Article or Comment from target

			newComment = Article {
				id:        uuid::v4(),
				author:    author,
				target:    target,
				body:      body,
				createdAt: time::now(),
				comments:  {},
			}

			updatedAuthorProfile = realworld::User{
				publishedComments: std::setInsert(
					author.publishedComments,
					newComment,
				),
				..follower
			}

			& = std::Transaction{
				effects: {
					// Update the author profile
					std::mutate(author, (u) => updatedAuthorProfile),

					// Create a new comment entity
					std::new(newComment),

					// Notify all the author about a new comment being published
					std::event(
						{target as t {
							Article then t.author
							Comment then t.author
						}},
						EvCommentPublished{
							comment: newComment,
						},
					),
				},
				data: CommentResolver{comment: newComment},
			}
		}
	}
}
