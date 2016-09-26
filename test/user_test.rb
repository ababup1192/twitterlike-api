require 'test/unit'
require 'sequel'
# load src file
require_relative '../src/user'

# UserTestClass
class UserTest < Test::Unit::TestCase
  DB = Sequel.sqlite('data/test.sqlite3')
  def test_db
    user_db = User.new(DB).db

    assert_not_nil user_db
  end

  def test_save_ok
    User.new(DB)
    DB.drop_table(:user)
    users = User.new(DB)
    result = users.save(name: 'abc', password: 'password')

    assert_equal [:ok, 1.to_json], result
  end

  def test_save_dup_error
    User.new(DB)
    DB.drop_table(:user)
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    result = users.save(name: 'abc', password: 'password')
    err_msg = { error: 'This user already exists.' }.to_json.freeze

    assert_equal [:error, err_msg], result
  end

  def test_auth
    User.new(DB)
    DB.drop_table(:user)
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    result = users.auth(name: 'abc', password: 'password')

    assert_equal [:ok, result[1]], result
  end

  def test_auth_failed
    User.new(DB)
    DB.drop_table(:user)
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    result = users.auth(name: 'abc', password: 'fail_pass')
    err_msg = { error: 'Authentication failed' }.to_json.freeze

    assert_equal [:error, err_msg], result
  end

  def test_auth_fail_user
    User.new(DB)
    DB.drop_table(:user)
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    result = users.auth(name: 'aiueo', password: 'password')
    err_msg = { error: 'This user does not exists.' }.to_json.freeze

    assert_equal [:error, err_msg], result
  end
end
