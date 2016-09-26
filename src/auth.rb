require 'openssl'
require 'securerandom'

# Authenticate utility module
module Auth
  # ハッシュ化されたパスワードを生成する
  def self.generate_hashed_password(password)
    OpenSSL::Digest::SHA256.hexdigest(password)
  end

  # ストレッチする
  def self.stretch(password)
    (1..1000).reduce(password) do |hashed_pass, _|
      Auth.generate_hashed_password(hashed_pass)
    end
  end

  # パスワードにソルトをかける
  def self.splinkle_salt(password, salt_length = 16)
    salt = SecureRandom.base64(salt_length)
    password_with_salt = password + salt
    { password: password_with_salt, salt: salt }
  end

  # ソルト付きパスワードを生成する
  def self.generate_hashed_password_with_salt(password, salt_length = 16)
    pass_with_salt = Auth.splinkle_salt(password, salt_length)
    hashed_pass = Auth.stretch(pass_with_salt[:password])
    pass_with_salt.update(password: hashed_pass)
  end

  # ソルトとパスワードを渡して、ハッシュを得る
  def self.hashed_password(password, salt)
    Auth.stretch(password + salt)
  end
end
