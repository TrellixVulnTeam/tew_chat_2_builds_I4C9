defmodule DB.Password do
  import Pbkdf2

  def hash_password(password), do: hash_pwd_salt(password)

  def verify_password(password, hash), do: verify_pass(password, hash)

  def dummy_verify(), do: no_user_verify()

end
