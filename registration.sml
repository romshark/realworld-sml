fragment realworld {
	"std" 1.0
	"url/url" 1.0
	"std/mail" 1.0
}

# registration is analogous to "POST /api/users"
registration = (
	username Username,
	email EmailAddress,
	password Password,
	bio ?String,
	image ?url::Url,
) -> (
	std::Mutation<UserResolver> or
	ErrEmailReserved or
	ErrUsernameReserved
) => {
	userByEmail = entity<User>(predicate: (u) => u.email == email)
	userByUsername = entity<User>(predicate: (u) => u.username == username)

	newUser = User{
		email:             email,
		username:          username,
		bio:               bio,
		image:             image,
		passwordHash:      newPasswordHash(password),
		publishedArticle:  {},
		publishedComments: {},
	}

	& = match {
		// Ensure email uniqueness
		userByEmail != Nil then ErrEmailReserved

		// Ensure username uniqueness
		userByUsername != Nil then ErrUsernameReserved

		else std::Mutation{
			effects: {
				// Create a new profile
				std::new(newUser),

				// Send account creation email
				mail::send(
					String from email,
					accountCreationEmail(username, email),
				),
			},
			data: UserResolver{user: newUser},
		}
	}
}
