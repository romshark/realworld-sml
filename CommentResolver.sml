fragment realworld

use {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
}

CommentResolver = resolver {
	comment Comment

	# id resolves the unique identifier of the comment
	id uuid::UuidV4 => this.comment.id

	# author resolves the comments author user
	author UserResolver => UserResolver{user: this.comment.author}

	# target resolves either the article or comment the comment targets
	target (ArticleResolver or CommentResolver) => this.comment.target as t {
		Article then ArticleResolver{article: t}
		Comment then CommentResolver{article: t}
	}

	# createdAt resolves the time the comment was created
	createdAt time::Time => this.comment.createdAt

	# updatedAt resolves either the time the comment was last edited
	# or nothing if the comment was yet never edited
	updatedAt ?time::Time => this.comment.updatedAt

	# body resolves the comment contents
	body CommentBody => this.comment.body

	# comments resolves all comments to this comment
	comments Array<CommentResolver> =>
		map(this.comment.comments, (c) => CommentResolver{comment: c})
}
