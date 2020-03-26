fragment realworld {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
}

# tUpdateArticle is analogous to "PUT /api/articles/:slug"
tUpdateArticle = (
	articleId uuid::UuidV4,
	title ?ArticleTitle,
	description ?ArticleDescription,
	body ?ArticleBody,
) -> (
	std::Mutation<ArticleResolver> or
	ErrUnauth or
	ErrArticleNotFound
) => {
	t = std::transaction()
	article = entity<Article>(
		transaction: t,
		predicate:   (a) => a.id == articleId,
	)

	& = match {
		// Ensure only the owner is allowed to update an article
		!isOwner(owner: article.author) then ErrUnauth

		// Ensure the article exists
		article == Nil then ErrArticleNotFound

		else {
			article = Article from article

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

			& = std::Mutation{
				transaction: t,
				effects: {
					// Update the article
					std::mutate(article, (u) => updatedArticle),
				},
				data: ArticleResolver{article: updatedArticle},
			}
		}
	}
}
