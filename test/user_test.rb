require 'test/unit'
require 'sequel'
# load src file
require_relative '../src/entity/user'
require_relative '../src/entity/session'
require_relative '../src/entity/follow'

# UserTestClass
class UserTest < Test::Unit::TestCase
  DB = Sequel.sqlite('data/test.sqlite3')

  def setup
    User.new(DB)
    Session.new(DB)
    Follow.new(DB)
    DB.drop_table(:user)
    DB.drop_table(:session)
    DB.drop_table(:follow)
  end

  def test_db
    user_db = User.new(DB).db

    assert_not_nil user_db
  end

  def test_save
    users = User.new(DB)
    status, = users.save(name: 'abc', password: 'password')

    assert_equal :ok, status
  end

  def test_save_fail
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    result = users.save(name: 'abc', password: 'password')
    err_msg = { error: 'The user already exists.' }

    assert_equal [:error, err_msg], result
  end

  def test_find
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    status, = users.find(1)

    assert_equal :ok, status
  end

  def test_auth
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    status, = users.auth(name: 'abc', password: 'password')

    assert_equal :ok, status
  end

  def test_auth_fail
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    result = users.auth(name: 'abc', password: 'fail_pass')
    err_msg = { error: 'Authentication failed.' }

    assert_equal [:error, err_msg], result
  end

  def test_auth_fail_user
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    result = users.auth(name: 'aiueo', password: 'password')
    err_msg = { error: 'The user does not exist.' }

    assert_equal [:error, err_msg], result
  end

  def test_auth_token
    users = User.new(DB)
    _, user = users.save(name: 'abc', password: 'password')
    status, = users.auth_token(id: user[:id], token: user[:token])

    assert_equal :ok, status
  end

  def test_auth_token_fail
    users = User.new(DB)
    _, user = users.save(name: 'abc', password: 'password')
    result = users.auth_token(id: user[:id], token: 'bbbb')
    err_msg = { error: 'Session Timeout.' }

    assert_equal [:error, err_msg], result
  end

  def test_unfollowers
    users = User.new(DB)
    follows = Follow.new(DB)
    users.save(name: 'abc', password: 'password')
    users.save(name: 'efg', password: 'password')
    users.save(name: 'hij', password: 'password')
    users.save(name: 'klm', password: 'password')
    follows.save(follow_id: 3, user_id: 1)

    unfollowers = users.unfollowers(1).map { |user| user[:id] }
    expected = [2, 4]

    assert_equal expected, unfollowers
  end
end
