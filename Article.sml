fragment realworld

use {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
}

Article = entity {
	id          uuid::UuidV4
	slug        Text
	title       ArticleTitle
	description ArticleDescription
	body        ArticleBody
	tags        Set<Tag>
	createdAt   time::Time
	updatedAt   ?time::Time
	author      User
	comments    Array<Comment>
}
