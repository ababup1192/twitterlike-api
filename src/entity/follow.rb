require 'sequel'
require 'sqlite3'
require_relative 'user'

# Model Follow
class Follow
  attr_accessor :db
  def initialize(db = Sequel.sqlite('data/app.sqlite3'))
    db.create_table? :follow do
      primary_key :id
      Integer :follow_id
      Integer :user_id
      Time :create_time
    end
    @sqlite_db = db
    @db = db[:follow]
  end

  def save(hash, time = Time.now)
    follow_id = hash[:follow_id]
    user_id = hash[:user_id]
    users = User.new(@sqlite_db).db
    follow_user = users.where(id: user_id).empty? == false
    followed_user = users.where(id: follow_id).empty? == false

    _save(user_id, follow_id, follow_user, followed_user, time)
  end

  def find(id)
    follow = @db.where(id: id)

    if follow.empty? == false
      [:ok, follow.first]
    else
      [:error, { error: 'The follow does not exist.' }]
    end
  end

  private def _save(user_id, follow_id, follow_user, followed_user, time)
    if follow_user && followed_user
      new_follow = { follow_id: follow_id, user_id: user_id, create_time: time }
      [:ok, new_follow.merge(id: @db.insert(new_follow))]
    else
      [:error, { error: 'The users do not exist.' }]
    end
  end
end
