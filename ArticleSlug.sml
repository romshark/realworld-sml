fragment {
	"std" 1.0
	"std/strings" 1.0
}

ArticleSlug = String

new ArticleSlug (s) => match {
	len(s) < 1 then std::error("invalid article slug (empty)")
}

# articleSlugFromTitle equals the slug of the given article title.
# For example "How to Train your Dragon" will
# be equal to "how-to-train-your-dragon"
articleSlugFromTitle = (t ArticleTitle) => {
	& = ArticleSlug from strings::toLower(j)
	j = strings::join(strings::fields(t), "-")
}

# uniqueArticleSlug equals a unique slug for the given article title.
# If any articles with a similar slug already exist it will fall back
# to numbered slugs such as "how-to-train-your-dragon-2"
uniqueArticleSlug = (title ArticleTitle) -> (ArticleSlug or std::Error) => {
	// This assumption is safe since ArticleTitle
	// is guaranteed to not be empty
	slug = ArticleSlug from articleSlugFromTitle(title)
	existing = entities<Article>(
		predicate: (a) => strings::hasPrefix(a.slug, slug),
	)

	& = match {
		// Use default, for example "how-to-train-your-dragon"
		len(existing) < 1 then slug

		// Fall back to numbered, for example "how-to-train-your-dragon-4"
		else strings::concat(slug, "-", strings::fmt("%d", len(existing)+1))
	}
}
