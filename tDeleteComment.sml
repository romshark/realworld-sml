fragment realworld {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
}

# tDeleteComment is analogous to "DELETE /api/articles/:slug/comments/:id"
tDeleteComment = (commentId uuid::UuidV4) -> (
	std::Transaction<Nil> or
	ErrUnauth or
	ErrCommentNotFound
) => {
	comment = entity<Comment>(predicate: (a) => a.id == commentId)

	& = match {
		// Ensure the comment exists
		comment == Nil then ErrCommentNotFound{}

		// Ensure users can only delete their own comments
		!isOwner(owner: (Comment from comment).author) then ErrUnauth{}

		else std::Transaction<Nil>{
			effects: [
				// Delete the comment entity
				// this will automatically delete any references to it
				std::delete(Comment from comment),
			],
		}
	}
}
