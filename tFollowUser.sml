fragment realworld

use {
	"std" 1.0
}

EvFollowed = event {
	follower User
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
	follower = entity<User>(predicate: (u) => u.username == followerUsername)
	followee = entity<User>(predicate: (u) => u.username == followeeUsername)

	& = match {
		// Ensure the follower exists
		follower == _ then ErrUserNotFound{}

		// Ensure the followee exists
		followee == _ then ErrFolloweeNotFound{}

		// Ensure the client is the follower
		!isOwner(owner: follower as User) then ErrUnauth{}

		// Ensure the user doesnt follow himself
		id(follower as User) == id(followee as User) then ErrFolloweeInvalid{}

		else {
			follower = follower as User
			followee = follower as User

			updatedFollowerProfile = User{
				following: std::setInsert(follower.following, followee),
				..follower
			}

			& = std::Transaction<UserResolver>{
				effects: [
					// Update the follower profile
					std::mutate(follower, (u) => updatedFollowerProfile),

					// Update the followee profile
					std::mutate(followee, (u) => User{
						followers: std::setInsert(followee.followers, follower),
						..followee
					}),

					// Notify the followee about a new follower subscription
					std::event([followee], EvFollowed{
						follower: follower,
					}),
				],
				data: UserResolver{user: updatedFollowerProfile},
			}
		}
	}
}
