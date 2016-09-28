require 'test/unit'
require 'sequel'
# load src file
require_relative '../src/entity/user'
require_relative '../src/entity/follow'

# TweetTestClass
class FollowTest < Test::Unit::TestCase
  DB = Sequel.sqlite('data/test.sqlite3')
  TIME1 = Time.local(2016, 10, 1, 0, 0, 0)
  TIME2 = Time.local(2016, 10, 1, 0, 1, 0)

  def setup
    User.new(DB)
    Follow.new(DB)
    DB.drop_table(:user)
    DB.drop_table(:follow)
  end

  def test_db
    follow_db = Follow.new(DB).db

    assert_not_nil follow_db
  end

  def test_save
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    users.save(name: 'def', password: 'password')
    follows = Follow.new(DB)

    expected = [:ok,
                { id: 1, follow_id: 2, user_id: 1, create_time: TIME1 }]
    result = follows.save({ follow_id: 2, user_id: 1 }, TIME1)

    assert_equal expected, result
  end

  def test_save_fail
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    follows = Follow.new(DB)

    result = follows.save(follow_id: 2, user_id: 1)
    err_msg = { error: 'The users do not exist.' }

    assert_equal [:error, err_msg], result
  end

  def test_find
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    users.save(name: 'def', password: 'password')
    follows = Follow.new(DB)

    expected = [:ok,
                { id: 1, follow_id: 2, user_id: 1, create_time: TIME1 }]
    follows.save({ follow_id: 2, user_id: 1 }, TIME1)
    result = follows.find(1)

    assert_equal expected, result
  end
end
