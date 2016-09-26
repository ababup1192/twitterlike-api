require 'sequel'
require 'sqlite3'
require 'json'
require_relative 'auth'

# Model User
class User
  attr_accessor :db
  def initialize(db = Sequel.sqlite('data/app.sqlite3'))
    db.create_table? :user do
      primary_key :id
      String :name, unique: true
      String :password
      String :salt
      Time :create_time
    end
    @db = db[:user]
  end

  def save(hash, time = Time.now)
    pass_with_salt = Auth.generate_hashed_password_with_salt(hash[:password])
    hash_with_salt_time = hash.update(pass_with_salt.merge(create_time: time))
    id = @db.insert(hash_with_salt_time)
    [:ok, id.to_json]
  rescue => _
    [:error, { error: 'This user already exists.' }.to_json]
  end

  def auth(hash)
    name = hash[:name]
    pass = hash[:password]
    user = @db.where(name: name).first
    if user.nil? == false
      salt = user[:salt]
      hashed_pass = Auth.hashed_password(pass, salt)
      success = @db.where(name: name, password: hashed_pass).empty? == false

      if success
        [:ok, nil]
      else
        [:error, { error: 'Authentication failed' }.to_json]
      end
    else
      [:error, { error: 'This user does not exists.' }.to_json]
    end
  end
end
