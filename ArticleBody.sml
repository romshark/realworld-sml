fragment realworld {
	"std" 1.0
}

ArticleBody = String

new ArticleBody (v) => match {
	len(v) < 1 then error("article body too short")
	len(v) > 131072 then error("article body too long")
}
