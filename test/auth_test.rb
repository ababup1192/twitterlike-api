require 'test/unit'
# load src file
require_relative '../src/auth'

# AuthTestClass
class AuthTest < Test::Unit::TestCase
  def test_splinkle_salt_length
    password = 'ps'
    pass_with_salt = Auth.splinkle_salt(password)

    expected = 20
    actual = pass_with_salt[:password].length

    assert_compare expected, '<=', actual
  end

  def test_splinkle_salt
    password = 'password'
    pass_with_salt = Auth.splinkle_salt(password, 15)
    salt_length = (15 * (4.0 / 3)).to_i
    p pass_with_salt

    expected = [password.length + salt_length, salt_length]
    actual = [pass_with_salt[:password].length, pass_with_salt[:salt].length]

    assert_equal expected, actual
  end

  def test_generate_hashed_password
    password = 'password'
    hashed_pass = Auth.generate_hashed_password(password)

    p hashed_pass

    assert_not_equal password, hashed_pass
  end
end
