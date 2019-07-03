fragment realworld

use {
	"std" 1.0
}

# UnfollowUser is analogous to "DELETE /api/profiles/:username/follow"
UnfollowUser = transaction(
	# followerUsername identifies the user to cancel the subcription for
	followerUsername Username,

	# followeeUsername identifies the user to be unfollowed
	followeeUsername Username,
) -> (
	std::Transaction<UserResolver> or
	ErrUnauth or
	ErrUserNotFound or
	ErrFolloweeNotFound
) => {
	follower = entity<User>(predicate: (u) => u.username == followerUsername)
	followee = entity<User>(predicate: (u) => u.username == followeeUsername)

	& = match {
		// Ensure users cannot unfollow on behalf of other users
		!isOwner(owner: follower) then ErrUnauth{}

		// Ensure the follower exists
		follower == _ then ErrUserNotFound{}

		// Ensure the followee exists
		followee == _ then ErrFolloweeNotFound{}

		else {
			follower = follower as User
			followee = followee as User

			updatedFollowerProfile = User{
				following: std::setRemove(follower.following, followee),
				..follower
			}

			& = std::Transaction<UserResolver>{
				effects: [
					// Update the follower profile
					std::mutate(follower, (u) => updatedFollowerProfile),

					// Update the followee profile
					std::mutate(followee, (u) => User{
						followers: std::setRemove(followee.followers, follower),
						..followee
					}),
				],
				data: UserResolver{user: updatedFollowerProfile},
			}
		}
	}
}
