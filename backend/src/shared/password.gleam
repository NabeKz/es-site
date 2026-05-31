import gleam/bit_array
import gleam/erlang/atom

@external(erlang, "crypto", "strong_rand_bytes")
fn strong_rand_bytes(n: Int) -> BitArray

@external(erlang, "crypto", "pbkdf2_hmac")
fn pbkdf2_hmac(
  digest: atom.Atom,
  password: BitArray,
  salt: BitArray,
  iterations: Int,
  derived_key_len: Int,
) -> BitArray

const iterations = 100_000

const key_len = 32

pub fn generate_salt() -> String {
  strong_rand_bytes(16)
  |> bit_array.base64_encode(True)
}

pub fn hash(password: String, salt: String, pepper: String) -> String {
  let pass_bits = <<{ password <> pepper }:utf8>>
  let salt_bits = case bit_array.base64_decode(salt) {
    Ok(b) -> b
    Error(_) -> <<salt:utf8>>
  }
  pbkdf2_hmac(atom.create("sha256"), pass_bits, salt_bits, iterations, key_len)
  |> bit_array.base64_encode(True)
}

pub fn verify(
  password: String,
  salt: String,
  pepper: String,
  stored_hash: String,
) -> Bool {
  hash(password, salt, pepper) == stored_hash
}
