fragment realworld {
	"std" 1.0
	"std/regex" 1.0
}

EmailAddress = String

new EmailAddress (v) => match {
	len(v) < 5 then error("email address too short")
	len(v) > 256 then error("email address too long")
	!regex::match(/.+@.+\..+/i, v) then error("invalid email address")
}
