require 'test/unit'
require 'sequel'
# load src file
require_relative '../src/user'
require_relative '../src/session'

# UserTestClass
class SessionTest < Test::Unit::TestCase
  DB = Sequel.sqlite('data/test.sqlite3')

  def setup
    User.new(DB)
    DB.drop_table(:user)
    DB.drop_table(:session)
  end

  def test_db
    session_db = Session.new(DB).db

    assert_not_nil session_db
  end

  def test_save
    users = User.new(DB)
    sessions = Session.new(DB)
    _, id_with_token = users.save(name: 'abc', password: 'password')
    id = JSON.parse(id_with_token, symbolize_names: true)[:id]
    result = sessions.save(id)

    p sessions.db.all

    assert_not_nil result
  end

  def test_save_fail
    sessions = Session.new(DB)
    result = sessions.save(1)

    assert_equal nil, result
  end

  def test_auth
    users = User.new(DB)
    sessions = Session.new(DB)
    _, id_with_token = users.save(name: 'abc', password: 'password')
    id_with_token_hash = JSON.parse(id_with_token, symbolize_names: true)
    id = id_with_token_hash[:id]
    token = id_with_token_hash[:token]
    result = sessions.auth(id, token)

    assert_true result
  end

  def test_auth_fail
    users = User.new(DB)
    sessions = Session.new(DB)
    _, id_with_token = users.save(name: 'abc', password: 'password')
    id_with_token_hash = JSON.parse(id_with_token, symbolize_names: true)
    id = id_with_token_hash[:id]
    result = sessions.auth(id, 'aaaaaaaaaaa')

    assert_false result
  end
end
