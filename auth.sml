fragment realworld {
	"std/jwt" 1.0
	"std/strings" 1.0
	"std/uuid" 1.0
	"std/conf" 1.0
}

# asOwner equals data if the current client is the owner of the resource,
# otherwise equals ErrUnauth
asOwner = <D>(owner User, data D) -> (D or ErrUnauth) => match {
	isOwner(owner) then data
	else ErrUnauth
}

# isOwner equals true if the current client is the owner,
# otherwise equals false
isOwner = (owner User) -> Bool => clientId() as cid {
	UserId then {
		& = u == User and (User from u).id == owner.id
		u = user(cid)
	}
	else false
}

# clientId equals the unique ID of the user if the client has a valid JWT token
# in the authorization header, otherwise equals false
clientId = ?UserId => {
	& = match {
		p[0] == "Bearer" and r == jwt::Token then {
			& = uuid::fromString(token.payload["uid"]) as uid {
				uuid::Uuidv4 then UserId from uid
			}
			token = jwt::Token from r
		}
	}
	r = jwt::fromString(
		p[1],
		jwtSecret,
		{jwt.signingMethodHMAC},
	)
	p = filter(
		strings::split(c.header["Authorization"], " "),
		(x) => match {
			x != "" then x
		},
	)
	c = std::Client from std::client()
}

user = (id UserId) => std::entity<User>(predicate: (u) => u.id == id)

jwtSecret = String from conf["jwtSecret"]

newAccessToken = (user User) => jwt::newToken(
	signingMethod: jwt::signingMethodHS256,
	claims:        user.id,
	secret:        jwtSecret,
)
