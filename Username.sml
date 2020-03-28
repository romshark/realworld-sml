fragment realworld {
	"std" 1.0
}

Username = String

new Username (v) => match {
	len(v) < 3 then error("invalid username (too short)")
	len(v) > 256 then error("invalid username (too long)")
}
