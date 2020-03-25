fragment realworld {
	"std" 1.0
}

AuthenticationResult = struct {
	email    EmailAddress
	token    String
	username Username
	bio      String
	image    String
}

# tAuthenticate is analogous to "POST /api/users/login"
tAuthenticate = (
	email    EmailAddress,
	password Text,
) -> (AuthenticationResult or ErrWrongCredentials) => {
	user = entity<realworld::User>(predicate: (u) => u.email == email)

	& = match {
		// Ensure the user exists
		user == Nil then ErrWrongCredentials

		// Ensure the password is correct
		!passwordEqual(password, (realworld::User from user).passwordHash) then
			ErrWrongCredentials

		else {
			u = realworld::User from user
			& = AuthenticationResult {
				email:    email,
				token:    newAccessToken(u),
				username: u.username,
				bio:      u.bio,
				image:    u.image,
			}
		}
	}
}
