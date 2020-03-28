fragment realworld {
	"std" 1.0
	"std/time" 1.0
}

CommentResolver = resolver {
	comment Comment
} {
	# id resolves the unique identifier of the comment
	id CommentId => this.comment.id

	# author resolves the comments author user
	author UserResolver => UserResolver{user: this.comment.author}

	# createdAt resolves the time the comment was created
	createdAt time::Time => this.comment.createdAt

	# updatedAt resolves either the time the comment was last edited
	# or nothing if the comment was yet never edited
	updatedAt ?time::Time => this.comment.updatedAt

	# body resolves the comment contents
	body CommentBody => this.comment.body

	# article resolves the corresponding article
	article ?ArticleResolver => this.comment.article as a {
		Article then ArticleResolver{article: a}
	}
}
