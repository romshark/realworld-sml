fragment realworld

use {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
}

# UpdateArticle is analogous to "PUT /api/articles/:slug"
UpdateArticle = transaction(
	articleId uuid::UuidV4,
	title ?ArticleTitle,
	description ?ArticleDescription,
	body ?ArticleBody,
) -> (
	std::Transaction<ArticleResolver> or
	ErrUnauth or
	ErrArticleNotFound
) => {
	article = entity<Article>(predicate: (a) => a.id == articleId)

	& = match {
		// Ensure only the owner is allowed to update an article
		!isOwner(owner: article.author) then ErrUnauth{}

		// Ensure the article exists
		article == _ then ErrArticleNotFound{}

		else {
			article = article as Article

			updatedArticle = Article {
				title: title as v {
					ArticleTitle then v
					else article.title
				},
				description: description as v {
					ArticleDescription then v
					else article.description
				},
				body: body as v {
					ArticleBody then v
					else article.body
				},
				..article
			}

			& = std::Transaction<ArticleResolver>{
				effects: [
					// Update the article
					std::mutate(article, (u) => updatedArticle),
				],
				data: ArticleResolver{article: updatedArticle},
			}
		}
	}
}
