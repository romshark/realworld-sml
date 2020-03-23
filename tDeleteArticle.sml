fragment realworld {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
}

# tDeleteArticle is analogous to "DELETE /api/articles/:slug"
tDeleteArticle = (articleId uuid::UuidV4) -> (
	std::Transaction<None> or
	ErrUnauth or
	ErrArticleNotFound
) => {
	article = entity<Article>(predicate: (a) => a.id == articleId)

	& = match {
		// Ensure the article exists
		article == None then ErrArticleNotFound{}

		// Ensure users can only delete their own articles
		!isOwner(owner: (Article from article).author) then ErrUnauth{}

		else std::Transaction<None>{
			effects: [
				// Delete the article entity
				// this will automatically delete any references to it
				std::delete(Article from article),
			],
		}
	}
}
