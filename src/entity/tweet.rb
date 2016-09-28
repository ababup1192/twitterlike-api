require 'sequel'
require 'sqlite3'
require 'json'
require_relative 'user'

# Model Tweet
class Tweet
  attr_accessor :db
  def initialize(db = Sequel.sqlite('data/app.sqlite3'))
    db.create_table? :tweet do
      primary_key :id
      String :text
      Integer :user_id
      Time :create_time
    end
    @sqlite_db = db
    @db = db[:tweet]
  end

  def save(hash, time = Time.now)
    user_id = hash[:user_id]
    text = hash[:text]
    users = User.new(@sqlite_db).db

    if users.where(id: user_id).empty? == false
      new_tweet = { text: text, user_id: user_id, create_time: time }
      id = @db.insert(new_tweet)
      [:ok, new_tweet.merge(id: id).to_json]
    else
      [:error, { error: 'The tweet user does not exist.' }.to_json]
    end
  end

  def find(id)
    tweet = @db.where(id: id)

    if tweet.empty? == false
      [:ok, tweet.first.to_json]
    else
      [:error, { error: 'The tweet does not exist.' }.to_json]
    end
  end

  def find_by_user_id(user_id)
    users = User.new(@sqlite_db).db

    if users.where(id: user_id).empty? == false
      [:ok, @db.where(user_id: user_id).all.to_json]
    else
      [:error, { error: 'The tweet user does not exist.' }.to_json]
    end
  end
end
