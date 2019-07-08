fragment realworld

use {
	"std" 1.0
	"std/time" 1.0
	"std/uuid" 1.0
}

Comment = entity {
	id        uuid::UuidV4
	author    realworld::User
	# target is nil if it was deleted
	target    ?(Article or Comment)
	createdAt time::Time
	updatedAt ?time::Time
	body      CommentBody
	comments  Array<Comment>
}
