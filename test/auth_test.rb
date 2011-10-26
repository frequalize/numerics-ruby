require 'test/unit'

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'fz/numerics'

class AuthTest < Test::Unit::TestCase

  def test_hash
    conn = Fz::Numerics.connect(:access_key => 'blah', :secret_key => 'moreblah')
    assert_equal 'blah', conn.access_key
    assert_equal 'moreblah', conn.secret_key
  end

  def test_yaml
    conn = Fz::Numerics.connect('test/assets/auth.yaml')
    assert_equal 'blah', conn.access_key
    assert_equal 'moreblah', conn.secret_key
  end

  def test_json
    conn = Fz::Numerics.connect('test/assets/auth.json')
    assert_equal 'blah', conn.access_key
    assert_equal 'moreblah', conn.secret_key
  end

  def test_env
    conn = Fz::Numerics.connect('test/assets/auth_env.yml', :production)
    assert_equal 'blah', conn.access_key
    assert_equal 'moreblah', conn.secret_key    

    conn = Fz::Numerics.connect('test/assets/auth_env.yml', :development)
    assert_equal 'foo', conn.access_key
    assert_equal 'foobar', conn.secret_key    

    assert_raises RuntimeError do
      Fz::Numerics.connect('test/assets/auth_env.yml', :test)
    end
  end

  def test_invalid
    conn = Fz::Numerics.connect(:access_key => 'invalid', :secret_key => 'notsecret')
    res = conn.list
    assert res[:error]
    assert res[:error].match(/no such access/), res[:error]
  end

end
