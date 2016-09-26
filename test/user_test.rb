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
    DB.drop_table(:user)
    users = User.new(DB)
    result = users.save(name: 'abc')

    assert_equal [:ok, 1.to_json], result
  end

  def test_save_dup_error
    DB.drop_table(:user)
    users = User.new(DB)
    users.save(name: 'abc')
    result = users.save(name: 'abc')
    err_msg = { error: 'This user already exists.' }.to_json.freeze

    assert_equal [:error, err_msg], result
  end
end
