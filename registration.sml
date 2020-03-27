fragment realworld {
	"std" 1.0
	"url/url" 1.0
	"std/mail" 1.0
}

ErrPasswordInvalid = error{
	minLen Uint32
	maxLen Uint32
}

# registration is analogous to "POST /api/users"
registration = (
	username Username,
	email EmailAddress,
	password Text,
	bio ?Text,
	image ?url::Url,
) -> (
	std::Mutation<UserResolver> or
	ErrPasswordInvalid or
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
		// Verify password
		len(password) < 8 or len(password) > 512 then ErrPasswordInvalid{
			minLen: 8,
			maxLen: 512,
		}

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
					Text from email,
					accountCreationEmail(username, email),
				),
			},
			data: UserResolver{user: newUser},
		}
	}
}
