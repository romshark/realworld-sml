fragment realworld {
	"std" 1.0
	"url/url" 1.0
	"std/mail" 1.0
}

ErrPasswordInvalid = error{
	minLen Uint32
	maxLen Uint32
}

# tRegister is analogous to "POST /api/users"
tRegister = (
	username Username,
	email EmailAddress,
	password Text,
	bio ?Text,
	image ?url::Url,
) -> (
	std::Transaction<UserResolver> or
	ErrPasswordInvalid or
	ErrEmailReserved or
	ErrUsernameReserved
) => {
	userByEmail = entity<realworld::User>(
		predicate: (u) => u.email == email,
	)
	userByUsername = entity<realworld::User>(
		predicate: (u) => u.username == username,
	)

	newUser = realworld::User{
		email:             email,
		username:          username,
		bio:               bio,
		image:             image,
		passwordHash:      newPasswordHash(password),
		publishedArticle:  [],
		publishedComments: [],
	}

	& = match {
		// Verify password
		len(password) < 8 or len(password) > 512 then ErrPasswordInvalid{
			minLen: 8,
			maxLen: 512,
		}

		// Ensure email uniqueness
		userByEmail != Nil then ErrEmailReserved{}

		// Ensure username uniqueness
		userByUsername != Nil then ErrUsernameReserved{}

		else std::Transaction<UserResolver>{
			effects: [
				// Create a new profile
				std::new(newUser),

				// Send account creation email
				mail::send(
					Text from email,
					accountCreationEmail(username, email),
				),
			],
			data: UserResolver{user: newUser},
		}
	}
}
