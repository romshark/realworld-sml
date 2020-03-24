fragment realworld {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
}

ArticleResolver = resolver {
	article Article
} {
	# id resolves the unique identifier of the article
	id uuid::UuidV4 => this.article.id

	# title resolves the article's title
	title ArticleTitle => this.article.title

	# description resolves the article's description
	description ArticleDescription String => this.article.description

	# body resolves the article contents
	body ArticleBody => this.article.body

	# tags resolves all tags assigned to the article
	tags Set<Tag> => this.article.tags

	# createdAt resolves the time the article was created
	createdAt time::Time => this.article.createdAt

	# updatedAt resolves either the time the article was last edited
	# or nothing if the article was yet never edited
	updatedAt ?time::Time => this.article.createdAt

	# author resolves the author user of the article
	author UserResolver => UserResolver{user: this.article.author}

	# comments resolves all comments to this article
	comments Array<CommentResolver> =>
		map(this.article.comments, (c) => CommentResolver{comment: c})
}
