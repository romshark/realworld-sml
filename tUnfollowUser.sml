fragment realworld {
	"std" 1.0
}

# tUnfollowUser is analogous to "DELETE /api/profiles/:username/follow"
tUnfollowUser = (
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
	t = std::transaction()
	follower = entity<User>(
		transaction: t,
		predicate:   (u) => u.username == followerUsername,
	)
	followee = entity<User>(
		transaction: t,
		predicate:   (u) => u.username == followeeUsername,
	)

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
				..follower
			}

			& = std::Mutation{
				transaction: t,
				effects: {
					// Update the follower profile
					std::mutate(follower, (u) => updatedFollowerProfile),

					// Update the followee profile
					std::mutate(followee, (u) => User{
						followers: std::setRemove(followee.followers, follower),
						..followee
					}),
				},
				data: UserResolver{user: updatedFollowerProfile},
			}
		}
	}
}
