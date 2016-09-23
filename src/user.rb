require 'sequel'
require 'sqlite3'
require 'json'

# Model User
class User
  def self.db(sqlite = Sequel.sqlite('data/app.sqlite3'))
    sqlite.create_table? :user do
      primary_key :id
      String :name, unique: true
      Time :create_time
    end
    sqlite[:user]
  end

  def self.save(hash, time = Time.now)
    hash_with_time = hash.merge(create_time: time)
    users = User.db
    id = users.insert(hash_with_time)
    [:ok, id.to_json]
  rescue => _
    [:error, { error: 'This user already exists.' }.to_json]
  end
end
