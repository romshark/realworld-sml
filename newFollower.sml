fragment realworld {
	"std" 1.0
}

# newFollower is analogous to "POST /api/profiles/:username/follow"
# resolving a mutation causing the creation of a subscription of the user
# identified by p:followerUsername to the user identified by p:followeeUsername
newFollower = (
	# followerUsername identifies the user to create the subcription for
	followerUsername Username,

	# followeeUsername identifies the user to be followed
	followeeUsername Username,
) -> (
	std::Mutation<UserResolver> or
	ErrUnauth or
	ErrUserNotFound or
	ErrFolloweeNotFound or
	ErrFolloweeInvalid
) => {
	follower = entity<User>(predicate: (u) => u.username == followerUsername)
	followee = entity<User>(predicate: (u) => u.username == followeeUsername)

	& = match {
		// Ensure the follower exists
		follower == Nil then ErrUserNotFound

		// Ensure the followee exists
		followee == Nil then ErrFolloweeNotFound

		// Ensure the client is the follower
		!isOwner(owner: User from follower) then ErrUnauth

		// Ensure the user doesnt follow himself
		id(User from follower) == id(User from followee) then
			ErrFolloweeInvalid

		else {
			follower = User from follower
			followee = User from followee

			updatedFollowerProfile = User{
				following: {
					..follower.following,
					followee,
				},
				..follower,
			}

			& = std::Mutation{
				effects: {
					// Update the follower profile
					std::mutated(follower, updatedFollowerProfile),

					// Update the followee profile
					std::mutated(followee, User{
						followers: {
							..followee.followers,
							follower,
						},
						..followee,
					}),
				},
				data: UserResolver{user: updatedFollowerProfile},
			}
		}
	}
}
