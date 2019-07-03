fragment realworld

# isOwner equals true if the current client is the owner,
# otherwise equals false
isOwner = (owner User) -> Bool => client() as u {
	User then match {
		id(u) == id(owner) then true
		else false
	}
}

# authOwner equals data if the current client is the owner,
# otherwise equals ErrUnauth
authOwner = (owner User, data @T) -> (@T or ErrUnauth) => match {
	isOwner(owner) then data
	else ErrUnauth{}
}
