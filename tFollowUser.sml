fragment realworld {
	"std" 1.0
}

EvFollowed = event {
	newFollower realworld::User

	newFollower UserResolver => UserResolver{user: this.follower}
}

# FollowUser is analogous to "POST /api/profiles/:username/follow"
FollowUser = transaction(
	# followerUsername identifies the user to create the subcription for
	followerUsername Username,

	# followeeUsername identifies the user to be followed
	followeeUsername Username,
) -> (
	std::Transaction<UserResolver> or
	ErrUnauth or
	ErrUserNotFound or
	ErrFolloweeNotFound or
	ErrFolloweeInvalid
) => {
	follower = entity<realworld::User>(
		predicate: (u) => u.username == followerUsername,
	)
	followee = entity<realworld::User>(
		predicate: (u) => u.username == followeeUsername,
	)

	& = match {
		// Ensure the follower exists
		follower == None then ErrUserNotFound{}

		// Ensure the followee exists
		followee == None then ErrFolloweeNotFound{}

		// Ensure the client is the follower
		!isOwner(owner: follower as realworld::User) then ErrUnauth{}

		// Ensure the user doesnt follow himself
		id(follower as realworld::User) == id(followee as realworld::User) then
			ErrFolloweeInvalid{}

		else {
			follower = follower as realworld::User
			followee = follower as realworld::User

			updatedFollowerProfile = realworld::User{
				following: std::setInsert(follower.following, followee),
				..follower
			}

			& = std::Transaction<UserResolver>{
				effects: [
					// Update the follower profile
					std::mutate(follower, (u) => updatedFollowerProfile),

					// Update the followee profile
					std::mutate(followee, (u) => realworld::User{
						followers: std::setInsert(followee.followers, follower),
						..followee
					}),

					// Notify the followee about a new follower subscription
					std::event([followee], EvFollowed{
						newFollower: follower,
					}),
				],
				data: UserResolver{user: updatedFollowerProfile},
			}
		}
	}
}
