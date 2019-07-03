fragment realworld

use {
	"std" 1.0
	"std/crypto/rand" 1.0
	"std/crypto/scrypt" 1.0
}

PasswordHash = struct {
	salt Array<Byte>
	hash Array<Byte>
}

newPasswordHash = (password Text) -> PasswordHash => {
	salt = rand::bytes(8)
	& = PasswordHash{
		salt: salt,
		hash: scrypt::key(pass, salt, 32768, 8, 1, 32),
	}
}

passwordEqual = (password Text, hash PasswordHash) -> Bool => {
	generated = scrypt::key(password, hash.salt, 32768, 8, 1, 32)
	& = match {
		generated == hash.hash then true
		else false
	}
}
