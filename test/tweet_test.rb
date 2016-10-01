require 'test/unit'
require 'sequel'
# load src file
require_relative '../src/entity/user'
require_relative '../src/entity/tweet'
require_relative '../src/entity/follow'

# TweetTestClass
class TweetTest < Test::Unit::TestCase
  DB = Sequel.sqlite('data/test.sqlite3')
  TIME1 = Time.local(2016, 10, 1, 0, 0, 0)
  TIME2 = Time.local(2016, 10, 1, 0, 1, 0)
  TEXT1 = 'first tweet'.freeze
  TEXT2 = 'second tweet'.freeze

  def setup
    User.new(DB)
    Tweet.new(DB)
    Follow.new(DB)
    DB.drop_table(:user)
    DB.drop_table(:tweet)
    DB.drop_table(:follow)
  end

  def test_db
    tweet_db = Tweet.new(DB).db

    assert_not_nil tweet_db
  end

  def test_save
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    tweets = Tweet.new(DB)

    expected = [:ok,
                { id: 1, text: TEXT1, user_id: 1,
                  name: 'abc', create_time: TIME1 }]
    result = tweets.save({ user_id: 1, text: TEXT1 }, TIME1)

    assert_equal expected, result
  end

  def test_save_fail
    tweets = Tweet.new(DB)
    result = tweets.save(user_id: 1, text: 'fail tweet')
    err_msg = { error: 'The tweet user does not exist.' }

    assert_equal [:error, err_msg], result
  end

  def test_find
    User.new(DB).save(name: 'abc', password: 'password')
    tweets = Tweet.new(DB)

    expected = [:ok,
                { id: 2, text: TEXT2, user_id: 1, name: 'abc',
                  create_time: TIME2 }]

    tweets.save({ user_id: 1, text: TEXT1 }, TIME1)
    result = tweets.save({ user_id: 1, text: TEXT2 }, TIME2)

    assert_equal expected, result
  end

  def test_find_by_user_id
    User.new(DB).save(name: 'abc', password: 'password')
    tweets = Tweet.new(DB)

    expected = [:ok, [
      { id: 1, text: TEXT1, user_id: 1, name: 'abc', create_time: TIME1 },
      { id: 2, text: TEXT2, user_id: 1, name: 'abc', create_time: TIME2 }
    ]]

    tweets.save({ user_id: 1, text: TEXT1 }, TIME1)
    tweets.save({ user_id: 1, text: TEXT2 }, TIME2)

    result = tweets.find_by_user_id(1)

    assert_equal expected, result
  end

  def test_find_by_user_id_fail
    tweets = Tweet.new(DB)
    err_msg = { error: 'The tweet user does not exist.' }
    result = tweets.find_by_user_id(-1)

    assert_equal [:error, err_msg], result
  end

  def test_timeline
    _create_user_test_timeline
    tweets = Tweet.new(DB)

    expected = [:ok, [
      { id: 1, text: TEXT1, user_id: 1, name: 'abc', create_time: TIME1 },
      { id: 2, text: TEXT2, user_id: 2, name: 'efg', create_time: TIME2 }
    ]]

    tweets.save({ user_id: 1, text: TEXT1 }, TIME1)
    tweets.save({ user_id: 2, text: TEXT2 }, TIME2)
    result = tweets.timeline(1)

    assert_equal expected, result
  end

  private def _create_user_test_timeline
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    users.save(name: 'efg', password: 'password')
    Follow.new(DB).save(follow_id: 2, user_id: 1)
  end
end
