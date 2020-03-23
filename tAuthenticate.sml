fragment realworld {
	"std" 1.0
}

# tAuthenticate is analogous to "POST /api/users/login"
tAuthenticate = (
	email    EmailAddress,
	password Text,
) -> (std::Transaction<UserResolver> or ErrWrongCredentials) => {
	user = entity<realworld::User>(predicate: (u) => u.email == email)

	& = match {
		// Ensure the user exists
		user == Nil then ErrWrongCredentials{}

		// Ensure the password is correct
		!passwordEqual(password, (realworld::User from user).passwordHash) then
			ErrWrongCredentials{}

		else {
			u = realworld::User from user
			& = std::Transaction<UserResolver>{
				effects: [std::auth(std::client(), u)],
				data:    UserResolver{user: u},
			}
		}
	}
}
