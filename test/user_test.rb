require 'test/unit'
require 'sequel'
# load src file
require_relative '../src/user'
require_relative '../src/session'

# UserTestClass
class UserTest < Test::Unit::TestCase
  DB = Sequel.sqlite('data/test.sqlite3')

  def setup
    User.new(DB)
    Session.new(DB)
    DB.drop_table(:user)
    DB.drop_table(:session)
  end

  def test_db
    user_db = User.new(DB).db

    assert_not_nil user_db
  end

  def test_save_ok
    users = User.new(DB)
    status, = users.save(name: 'abc', password: 'password')

    assert_equal :ok, status
  end

  def test_save_dup_error
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    result = users.save(name: 'abc', password: 'password')
    err_msg = { error: 'This user already exists.' }.to_json.freeze

    assert_equal [:error, err_msg], result
  end

  def test_auth
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    result = users.auth(name: 'abc', password: 'password')

    assert_equal [:ok, result[1]], result
  end

  def test_auth_failed
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    result = users.auth(name: 'abc', password: 'fail_pass')
    err_msg = { error: 'Authentication failed' }.to_json.freeze

    assert_equal [:error, err_msg], result
  end

  def test_auth_fail_user
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    result = users.auth(name: 'aiueo', password: 'password')
    err_msg = { error: 'This user does not exists.' }.to_json.freeze

    assert_equal [:error, err_msg], result
  end

  def test_auth_token
    users = User.new(DB)
    _, user_json = users.save(name: 'abc', password: 'password')
    user = JSON.parse(user_json, symbolize_names: true)
    status, uj = users.auth_token(id: user[:id], token: user[:token])

    p uj

    assert_equal :ok, status
  end

  def test_auth_token_fail
    users = User.new(DB)
    _, user_json = users.save(name: 'abc', password: 'password')
    user = JSON.parse(user_json, symbolize_names: true)
    status, = users.auth_token(id: user[:id], token: 'bbbb')

    assert_equal :error, status
  end
end
