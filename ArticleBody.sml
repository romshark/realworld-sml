fragment realworld {
	"std" 1.0
}

ArticleBody = String

new ArticleBody (v) => match {
	v == "" then error("invalid article body (empty)")
	len(v) > 131072 then error("invalid article body (too long)")
}
