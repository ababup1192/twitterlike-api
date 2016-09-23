require 'sequel'
require 'sqlite3'
require 'json'

# Model User
class User
  attr_accessor :db
  def initialize(db = Sequel.sqlite('data/app.sqlite3'))
    db.create_table? :user do
      primary_key :id
      String :name, unique: true
      Time :create_time
    end
    @db = db[:user]
  end

  def save(hash, time = Time.now)
    hash_with_time = hash.merge(create_time: time)
    id = @db.insert(hash_with_time)
    [:ok, id.to_json]
  rescue => _
    [:error, { error: 'This user already exists.' }.to_json]
  end
end
