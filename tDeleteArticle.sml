fragment realworld

use {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
}

# DeleteArticle is analogous to "DELETE /api/articles/:slug"
DeleteArticle = transaction(
	articleId uuid::UuidV4,
) -> (
	std::Transaction<_> or
	ErrUnauth or
	ErrArticleNotFound
) => {
	article = entity<Article>(predicate: (a) => a.id == articleId)

	& = match {
		// Ensure the article exists
		article == _ then ErrArticleNotFound{}

		// Ensure users can only delete their own articles
		!isOwner(owner: (article as Article).author) then ErrUnauth{}

		else std::Transaction<_>{
			effects: [
				// Delete the article entity
				// this will automatically delete any references to it
				std::delete(article as Article),
			],
		}
	}
}
