require 'sequel'
require 'sqlite3'
require 'json'
require_relative 'session'
require_relative '../utils/auth'

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
    @sqlite_db = db
    @db = db[:user]
  end

  def save(hash, time = Time.now)
    pass_with_salt = Auth.generate_hashed_password_with_salt(hash[:password])
    hash_with_salt_time = hash.update(pass_with_salt.merge(create_time: time))
    id = @db.insert(hash_with_salt_time)
    token = Session.new(@sqlite_db).save(id)
    [:ok, { id: id, token: token }.to_json]
  rescue => _
    [:error, { error: 'The user already exists.' }.to_json]
  end

  def find(id)
    user = @db.where(id: id)
    if user.empty? == false
      [:ok, user.first.to_json]
    else
      [:error, { error: 'The user does not exist.' }.to_json]
    end
  end

  def auth(hash)
    name = hash[:name]
    pass = hash[:password]
    user = @db.where(name: name).first
    if user.nil? == false
      _auth(user, name, pass)
    else
      [:error, { error: 'The user does not exist.' }.to_json]
    end
  end

  def auth_token(hash)
    id = hash[:id]
    token = hash[:token]

    if Session.new(@sqlite_db).auth(id, token)
      user = @db.where(id: id).first
      name = user[:name]
      [:ok, { id: id, name: name, token: token }.to_json]
    else
      [:error, { error: 'Authentication failed' }.to_json]
    end
  end

  private def _auth(user, name, pass)
    salt = user[:salt]
    hashed_pass = Auth.hashed_password(pass, salt)
    user = @db.where(name: name, password: hashed_pass)

    if user.empty? == false
      _auth_msg(user.first)
    else
      [:error, { error: 'Authentication failed' }.to_json]
    end
  end

  private def _auth_msg(user)
    id = user[:id]
    name = user[:name]
    token = Session.new(@sqlite_db).save(id)
    [:ok, { id: id, name: name, token: token }.to_json]
  end
end
