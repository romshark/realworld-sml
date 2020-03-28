fragment realworld {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
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
	author = entity<User>(predicate: (u) => u.username == authorUsername)
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
