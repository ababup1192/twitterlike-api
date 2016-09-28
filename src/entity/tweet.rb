require 'sequel'
require 'sqlite3'
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
      [:ok, new_tweet.merge(id: id)]
    else
      [:error, { error: 'The tweet user does not exist.' }]
    end
  end

  def find(id)
    tweet = @db.where(id: id)

    if tweet.empty? == false
      [:ok, tweet.first]
    else
      [:error, { error: 'The tweet does not exist.' }]
    end
  end

  def find_by_user_id(user_id)
    users = User.new(@sqlite_db).db

    if users.where(id: user_id).empty? == false
      tweets = @db.where(user_id: user_id).all
      [:ok, tweets]
    else
      [:error, { error: 'The tweet user does not exist.' }]
    end
  end
end
