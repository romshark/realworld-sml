fragment realworld {
	"std" 1.0
}

EvFollowed = event {
	newFollower realworld::User

	newFollower UserResolver => UserResolver{user: this.follower}
}

# tFollowUser is analogous to "POST /api/profiles/:username/follow"
tFollowUser = (
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
		follower == Nil then ErrUserNotFound

		// Ensure the followee exists
		followee == Nil then ErrFolloweeNotFound

		// Ensure the client is the follower
		!isOwner(owner: realworld::User from follower) then ErrUnauth

		// Ensure the user doesnt follow himself
		id(realworld::User from follower) == id(realworld::User from followee) then
			ErrFolloweeInvalid

		else {
			follower = realworld::User from follower
			followee = realworld::User from followee

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
