require 'test/unit'
require 'sequel'
require 'json'
# load src file
require_relative '../src/entity/user'
require_relative '../src/entity/tweet'

# TweetTestClass
class UserTest < Test::Unit::TestCase
  DB = Sequel.sqlite('data/test.sqlite3')
  TIME1 = Time.local(2016, 10, 1, 0, 0, 0)
  TIME2 = Time.local(2016, 10, 1, 0, 1, 0)
  TEXT1 = 'first tweet'.freeze
  TEXT2 = 'second tweet'.freeze

  def setup
    User.new(DB)
    Tweet.new(DB)
    DB.drop_table(:user)
    DB.drop_table(:tweet)
  end

  def test_db
    user_db = User.new(DB).db

    assert_not_nil user_db
  end

  def test_save
    users = User.new(DB)
    users.save(name: 'abc', password: 'password')
    tweets = Tweet.new(DB)

    expected = [:ok,
                { id: 1, text: TEXT1, user_id: 1, create_time: TIME1.to_s }]
    status, json = tweets.save(1, TEXT1, TIME1)

    assert_equal expected, [status, JSON.parse(json, symbolize_names: true)]
  end

  def test_save_fail
    tweets = Tweet.new(DB)
    result = tweets.save(1, 'fail tweet')
    err_msg = { error: 'The tweet user does not exist.' }.to_json.freeze

    assert_equal [:error, err_msg], result
  end

  def test_find
    User.new(DB).save(name: 'abc', password: 'password')
    tweets = Tweet.new(DB)

    expected = [:ok,
                { id: 2, text: TEXT2, user_id: 1, create_time: TIME2.to_s }]

    tweets.save(1, TEXT1, TIME1)
    status, json = tweets.save(1, TEXT2, TIME2)

    assert_equal expected, [status, JSON.parse(json, symbolize_names: true)]
  end
end
