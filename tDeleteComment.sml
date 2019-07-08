fragment realworld

use {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
}

# DeleteComment is analogous to "DELETE /api/articles/:slug/comments/:id"
DeleteComment = transaction(
	commentId uuid::UuidV4,
) -> (
	std::Transaction<None> or
	ErrUnauth or
	ErrCommentNotFound
) => {
	comment = entity<Comment>(predicate: (a) => a.id == commentId)

	& = match {
		// Ensure the comment exists
		comment == None then ErrCommentNotFound{}

		// Ensure users can only delete their own comments
		!isOwner(owner: (comment as Comment).author) then ErrUnauth{}

		else std::Transaction<None>{
			effects: [
				// Delete the comment entity
				// this will automatically delete any references to it
				std::delete(comment as Comment),
			],
		}
	}
}
