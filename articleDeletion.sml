fragment realworld {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
}

# articleDeletion is analogous to "DELETE /api/articles/:slug" and resolves
# to a mutation causing permanent deletion of an article identified by p:articleId
# in case of success.
articleDeletion = (articleId uuid::UuidV4) -> (
	std::Mutation<Nil> or
	ErrUnauth or
	ErrArticleNotFound
) => {
	article = entity<Article>(predicate: (a) => a.id == articleId)

	& = match {
		// Ensure the article exists
		article == Nil then ErrArticleNotFound

		// Ensure users can only delete their own articles
		!isOwner(owner: (Article from article).author) then ErrUnauth

		else std::Mutation<Nil>{
			effects: {
				// Delete the article entity
				// this will automatically delete any references to it
				std::delete(Article from article),
			},
		}
	}
}
