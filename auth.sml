fragment realworld

# isOwner equals true if the current client is the owner,
# otherwise equals false
isOwner = (owner User) -> Bool => client() as u {
	User then match {
		id(u) == id(owner) then true
		else false
	}
	else false
}

# authOwner equals data if the current client is the owner,
# otherwise equals ErrUnauth
authOwner = <D>(owner User, data D) -> (D or ErrUnauth) => match {
	isOwner(owner) then data
	else ErrUnauth{}
}
