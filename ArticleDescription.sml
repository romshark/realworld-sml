fragment realworld {
	"std" 1.0
}

ArticleDescription = Text

new ArticleDescription (v) => match {
	len(v) < 2 then error("article description too short")
	len(v) > 512 then error("article description too long")
}
