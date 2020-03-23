fragment realworld {
	"std" 1.0
}

Username = Text

new Username (v) => match {
	len(v) < 3 then error("username too short")
	len(v) > 256 then error("username too long")
}
