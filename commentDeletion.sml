fragment realworld {
	"std" 1.0
	"std/time" 1.0
}

# commentDeletion is analogous to "DELETE /api/articles/:slug/comments/:id"
# resolving a mutation causing permanent deletion of the comment identified
# by p:commentId in case of success
commentDeletion = (commentId CommentId) -> (
	std::Mutation<Nil> or
	ErrUnauth or
	ErrCommentNotFound
) => {
	comment = entity<Comment>(predicate: (a) => a.id == commentId)

	& = match {
		// Ensure the comment exists
		comment == Nil then ErrCommentNotFound

		// Ensure users can only delete their own comments
		!isOwner(owner: (Comment from comment).author) then ErrUnauth

		else std::Mutation<Nil>{
			effects: {
				// Delete the comment entity
				// this will automatically delete any references to it
				std::delete(Comment from comment),
			},
		}
	}
}
