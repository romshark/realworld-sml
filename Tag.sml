fragment realworld {
	"std" 1.0
}

Tag = String

new Tag (v) => match {
	v == "" then error("invalid tag (empty)")
	len(v) > 48 then error("invalid tag (too long)")
}
