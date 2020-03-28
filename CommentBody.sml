fragment realworld {
	"std" 1.0
}

CommentBody = String

new CommentBody (v) => match {
	v == "" then error("invalid comment body (empry)")
	len(v) > 65536 then error("invalid comment body (too long)")
}
