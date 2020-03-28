fragment realworld {
	"std" 1.0
}

ArticleDescription = String

new ArticleDescription (v) => match {
	len(v) < 2 then error("invalid article description (too short)")
	len(v) > 512 then error("invalid article description (too long)")
}
