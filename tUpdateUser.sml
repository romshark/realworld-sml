fragment realworld {
	"std" 1.0
	"url/url" 1.0
}

NoChange = struct{}

# tUpdateUser is analogous to "PUT /api/user"
tUpdateUser = (
	# username identifies the user to be updated
	username Username,
	
	# newUsername doesn't change realworld::User.email when not given
	newUsername ?Username,

	# newEmail doesn't change realworld::User.email when not given
	newEmail ?EmailAddress,

	# newBio resets realworld::User.bio to unset when not given,
	# use NoChange to leave realworld::User.bio unchanged
	newBio ?(Text or NoChange),

	# newImage resets realworld::User.image to unset when not given,
	# use NoChange to leave realworld::User.image unchanged
	newImage ?(url::Url or NoChange),
) -> (
	std::Transaction<UserResolver> or
	ErrUnauth or
	ErrUserNotFound or
	ErrUsernameReserved or
	ErrEmailReserved
) => {
	user = entity<realworld::User>(predicate: (u) => u.username == username)
	userByNewUsername = entity<realworld::User>(
		predicate: (u) => u.username == newUsername,
	)
	userByNewEmail = entity<realworld::User>(
		predicate: (u) => u.email == newEmail,
	)

	& = match {
		// Ensure the profile exists
		user == Nil then ErrUserNotFound{}

		// Ensure only the owner is allowed to update a profile
		!isOwner(owner: realworld::User from user) then ErrUnauth{}

		// Ensure username uniqueness
		userByNewUsername != Nil then ErrUsernameReserved{}

		// Ensure email uniqueness
		userByNewEmail != Nil then ErrEmailReserved{}

		else {
			user = realworld::User from user

			updatedProfile = realworld::User{
				username: newUsername as v {
					Username then v
					else user.username
				},
				email: newEmail as v {
					EmailAddress then v
					else user.email
				},
				bio: newBio as v {
					NoChange then user.bio
					Text then v
					else Nil
				},
				image: newImage as v {
					NoChange then user.image
					url::Url then v
					else Nil
				},
				..user
			}

			& = std::Transaction<UserResolver>{
				effects: [
					// Update the profile
					std::mutate(user, (u) => updatedProfile),
				],
				data: UserResolver{user: updatedProfile},
			}
		}
	}
}
