fragment realworld {
	"std" 1.0
}

CommentBody = Text

new CommentBody (v) => match {
	len(v) < 1 then error("comment body too short")
	len(v) > 65536 then error("comment body too long")
}
