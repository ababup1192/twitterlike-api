require 'openssl'
require 'securerandom'

# Authenticate utility module
module Auth
  # パスワードにソルトをかける
  def self.splinkle_salt(password, salt_length = 16)
    salt = SecureRandom.base64(salt_length)
    password_with_salt = password + salt
    { password: password_with_salt, salt: salt }
  end

  # ハッシュ化されたパスワードを生成する
  def self.generate_hashed_password(password)
    OpenSSL::Digest::SHA256.digest(password)
  end
end
