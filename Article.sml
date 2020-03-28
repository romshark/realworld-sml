fragment realworld {
	"std" 1.0
	"std/time" 1.0
}

Article = entity {
	slug        ArticleSlug
	title       ArticleTitle
	description ArticleDescription
	body        ArticleBody
	tags        Set<Tag>
	createdAt   time::Time
	updatedAt   ?time::Time
	author      User
	comments    Array<Comment>
}
