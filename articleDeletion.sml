fragment realworld {
	"std" 1.0
	"std/time" 1.0
}

# articleDeletion is analogous to "DELETE /api/articles/:slug"
# resolving a mutation causing permanent deletion of an article
# identified by p:slug in case of success
articleDeletion = (slug String) -> (
	std::Mutation<Nil> or
	ErrUnauth or
	ErrArticleNotFound
) => {
	article = entity<Article>(predicate: (a) => a.id == slug)

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
