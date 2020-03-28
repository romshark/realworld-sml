fragment realworld {
	"std" 1.0
	"std/time" 1.0
}

CommentId = struct {
	slug  ArticleSlug
	index Uint64
}

Comment = entity {
	id        CommentId
	author    User	
	createdAt time::Time
	updatedAt ?time::Time
	body      CommentBody

	# article is t:Nil if it was deleted
	article ?Article
}
