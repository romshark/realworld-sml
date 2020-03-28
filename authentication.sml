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

# authentication is analogous to `POST /api/users/login`
# resolving a t:AuthenticationResult with a valid JWT token
authentication = (
	email    String,
	password String,
) -> (AuthenticationResult or ErrWrongCredentials) => {
	user = entity<User>(predicate: (u) => u.email == email)
	email = EmailAddress from email

	& = match {
		// Ensure email is a valid email address
		email == std::Error then ErrWrongCredentials

		// Ensure the user exists
		user == Nil then ErrWrongCredentials

		// Ensure the password is correct
		!passwordEqual(password, (User from user).passwordHash) then
			ErrWrongCredentials

		else {
			u = User from user
			& = AuthenticationResult {
				email:    EmailAddress from email,
				token:    newAccessToken(u),
				username: u.username,
				bio:      u.bio,
				image:    u.image,
			}
		}
	}
}
