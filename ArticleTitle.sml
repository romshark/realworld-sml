fragment realworld {
	"std" 1.0
}

ArticleTitle = String

new ArticleTitle (v) => match {
	len(v) < 2 then error("article title too short")
	len(v) > 256 then error("article title too long")
}
