fragment realworld {
	"std" 1.0
}

# Authenticate is analogous to "POST /api/users/login"
Authenticate = transaction(
	email    EmailAddress,
	password Text,
) -> (std::Transaction<UserResolver> or ErrWrongCredentials) => {
	user = entity<realworld::User>(predicate: (u) => u.email == email)

	& = match {
		// Ensure the user exists
		user == None then ErrWrongCredentials{}

		// Ensure the password is correct
		!passwordEqual(password, (user as realworld::User).passwordHash) then
			ErrWrongCredentials{}

		else {
			u = user as realworld::User
			& = std::Transaction<UserResolver>{
				effects: [std::auth(std::client(), u)],
				data:    UserResolver{user: u},
			}
		}
	}
}
