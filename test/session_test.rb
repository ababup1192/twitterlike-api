require 'test/unit'
require 'sequel'
# load src file
require_relative '../src/user'
require_relative '../src/session'

# UserTestClass
class SessionTest < Test::Unit::TestCase
  DB = Sequel.sqlite('data/test.sqlite3')
  def test_db
    session_db = Session.new(DB).db

    assert_not_nil session_db
  end

  def test_save
    User.new(DB)
    DB.drop_table(:user)
    DB.drop_table(:session)
    users = User.new(DB)
    sessions = Session.new(DB)
    _, id = users.save(name: 'abc', password: 'password')
    result = sessions.save(id.to_i)

    assert_equal 1, result
  end
end
