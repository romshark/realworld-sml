fragment realworld {
	"std" 1.0
}

Tag = String

new Tag (v) => match {
	len(v) < 1 then error("tag too short")
	len(v) > 48 then error("tag too long")
}
