fragment realworld

use {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
}

EvArticlePublished = event {
	article Article
}

# PublishComment is analogous to "POST /api/articles/:slug/comments"
PublishComment = transaction(
	targetId uuid::UuidV4,
	authorUsername Username,
	body CommentBody,
) -> (
	std::Transaction<CommentResolver> or
	ErrUnauth or
	ErrUserNotFound or
	ErrTargetNotFound
) => {
	author = entity<User>(predicate: (u) => u.username == authorUsername)
	articleById = entity<Article>(predicate: (a) => a.id == targetId)
	commentById = entity<Comment>(predicate: (c) => c.id == targetId)
	target = match {
		articleById == Article then articleById as Article
		commentById == Comment then commentById as Comment
	}

	& = match {
		// Ensure the author exists
		author == _ then ErrUserNotFound{}

		// Ensure the target exists
		target == _ then ErrTargetNotFound{}

		// Ensure users cant publish posts on behalf of other users
		!isOwner(owner: author as User) then ErrUnauth{}

		else {
			author = author as User
			target = target as Article or Comment

			newComment = Article {
				id:        uuid::v4(),
				author:    author,
				target:    target,
				body:      body,
				createdAt: time::now(),
				comments:  [],
			}

			updatedAuthorProfile = User{
				publishedComments: std::setInsert(
					author.publishedComments,
					newComment,
				),
				..follower
			}

			& = std::Transaction<CommentResolver>{
				effects: [
					// Update the author profile
					std::mutate(author, (u) => updatedAuthorProfile),

					// Create a new comment entity
					std::new(newComment),

					// Notify all the author about a new comment being published
					std::event(
						target as t {
							Article then t.author
							Comment then t.author
						},
						EvArticlePublished{
							follower: follower,
						},
					),
				],
				data: CommentResolver{comment: newComment},
			}
		}
	}
}
