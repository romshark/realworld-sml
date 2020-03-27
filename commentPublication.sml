fragment realworld {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
}

EvCommentPublished = event {
	comment Comment

	comment CommentResolver => CommentResolver{comment: this.comment}
}

# commentPublication is analogous to "POST /api/articles/:slug/comments"
# resolving a mutation causing the creation of a new t:Comment entity
# on the the t:Article or t:Comment identified by p:targetId
# in case of success
commentPublication = (
	targetId uuid::UuidV4,
	authorUsername Username,
	body CommentBody,
) -> (
	std::Mutation<CommentResolver> or
	ErrUnauth or
	ErrUserNotFound or
	ErrTargetNotFound
) => {
	t = std::transaction()
	author = entity<User>(
		transaction: t,
		predicate:   (u) => u.username == authorUsername,
	)
	articleById = entity<Article>(
		transaction: t,
		predicate:   (a) => a.id == targetId,
	)
	commentById = entity<Comment>(
		transaction: t,
		predicate:   (c) => c.id == targetId,
	)
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
		!isOwner(owner: User from author) then ErrUnauth

		else {
			author = User from author
			target = Article or Comment from target

			newComment = Article {
				id:        uuid::v4(),
				author:    author,
				target:    target,
				body:      body,
				createdAt: time::now(),
				comments:  {},
			}

			updatedAuthorProfile = User{
				publishedComments: std::setInsert(
					author.publishedComments,
					newComment,
				),
				..follower
			}

			& = std::Mutation{
				transaction: t,
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
