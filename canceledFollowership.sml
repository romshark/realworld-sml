fragment realworld {
	"std" 1.0
}

# canceledFollowership is analogous to "DELETE /api/profiles/:username/follow"
# resolving a mutation causing the cancelation of a subscription of the user
# identified by p:followerUsername to the user identified by p:followeeUsername
canceledFollowership = (
	# followerUsername identifies the user to cancel the subcription for
	followerUsername Username,

	# followeeUsername identifies the user to be unfollowed
	followeeUsername Username,
) -> (
	std::Mutation<UserResolver> or
	ErrUnauth or
	ErrUserNotFound or
	ErrFolloweeNotFound
) => {
	follower = entity<User>(predicate: (u) => u.username == followerUsername)
	followee = entity<User>(predicate: (u) => u.username == followeeUsername)

	& = match {
		// Ensure users cannot unfollow on behalf of other users
		!isOwner(owner: follower) then ErrUnauth

		// Ensure the follower exists
		follower == Nil then ErrUserNotFound

		// Ensure the followee exists
		followee == Nil then ErrFolloweeNotFound

		else {
			follower = User from follower
			followee = User from followee

			updatedFollowerProfile = User{
				following: std::setRemove(follower.following, followee),
				..follower,
			}

			& = std::Mutation{
				effects: {
					// Update the follower profile
					std::mutate(follower, updatedFollowerProfile),

					// Update the followee profile
					std::mutate(followee, User{
						followers: std::setRemove(followee.followers, follower),
						..followee,
					}),
				},
				data: UserResolver{user: updatedFollowerProfile},
			}
		}
	}
}
