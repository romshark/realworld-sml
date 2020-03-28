fragment realworld {
	"std" 1.0
	"std/crypto/rand" 1.0
	"std/crypto/scrypt" 1.0
}

minPasswordLen = 8
maxPasswordLen = 512

Password = String

new Password (p) => match {
	len(password) < minPasswordLen or
		len(password) > maxPasswordLen then error<ErrPasswordInvalid>{
		actual: len(password),
		minLen: minPasswordLen,
		maxLen: maxPasswordLen,
	}
}

PasswordHash = struct {
	salt Array<Byte>
	hash Array<Byte>
}

newPasswordHash = (password String) -> PasswordHash => {
	salt = rand::bytes(8)
	& = PasswordHash{
		salt: salt,
		hash: scrypt::key(pass, salt, 32768, 8, 1, 32),
	}
}

passwordEqual = (password String, hash PasswordHash) -> Bool => {
	generated = scrypt::key(password, hash.salt, 32768, 8, 1, 32)
	& = match {
		generated == hash.hash then true
		else false
	}
}
