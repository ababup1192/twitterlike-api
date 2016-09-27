require 'sequel'
require 'sqlite3'
require 'json'
require 'securerandom'
require_relative 'user'

# Model Session
class Session
  attr_accessor :db
  def initialize(db = Sequel.sqlite('data/app.sqlite3'))
    db.create_table? :session do
      primary_key :id
      String :token, unique: true
      Integer :user_id, unique: true
      Time :create_time
    end
    @sqlite_db = db
    @db = db[:session]
  end

  def save(user_id, time = Time.now)
    users = User.new(@sqlite_db).db

    return if users.where(id: user_id).empty?
    token = SecureRandom.base64(50)
    # Delete old session
    @db.where(user_id: user_id).delete

    new_session = { token: token, user_id: user_id, create_time: time }
    @db.insert(new_session)
    token
  end

  def auth(user_id, token)
    @db.where(user_id: user_id, token: token).empty? == false
  end
end
