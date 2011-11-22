require 'test/unit'

if !ARGV.include?('gem')
  $:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
end
require 'numerics'

class AuthTest < Test::Unit::TestCase

  def test_hash
    conn = Numerics.connect(:access_key => 'blah', :secret_key => 'moreblah')
    assert_equal 'blah', conn.access_key
    assert_equal 'moreblah', conn.secret_key
    assert conn.enabled?
    conn = Numerics.connect(:access_key => 'blah', :secret_key => 'moreblah', :disabled => true)
    assert conn.disabled?
  end

  def test_yaml
    conn = Numerics.connect('test/assets/auth.yaml')
    assert_equal 'blah', conn.access_key
    assert_equal 'moreblah', conn.secret_key
  end

  def test_json
    conn = Numerics.connect('test/assets/auth.json')
    assert_equal 'blah', conn.access_key
    assert_equal 'moreblah', conn.secret_key
  end

  def test_env
    conn = Numerics.connect('test/assets/auth_env.yml', :production)
    assert_equal 'blah', conn.access_key
    assert_equal 'moreblah', conn.secret_key
    assert conn.enabled?

    conn = Numerics.connect('test/assets/auth_env.yml', :development)
    assert_equal 'foo', conn.access_key
    assert_equal 'foobar', conn.secret_key    
    assert conn.disabled?

    assert_raises RuntimeError do
      Numerics.connect('test/assets/auth_env.yml', :test)
    end
  end

  def test_invalid
    conn = Numerics.connect(:access_key => 'invalid', :secret_key => 'notsecret', :host => '127.0.0.1', :port => 9000)
    res = conn.list
    assert res[:error]
    assert res[:error].match(/no such access/), res[:error]
  end

end
