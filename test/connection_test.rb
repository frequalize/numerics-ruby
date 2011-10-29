require 'test/unit'

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'fz/numerics'

class ConnectionTest < Test::Unit::TestCase

  def conn
    @conn ||= Fz::Numerics.connect(:access_key => 'master_empty', :secret_key => '5ekR1Tt')
  end

  def test_001_meta
    assert_equal [], conn.list[:data]

    assert conn.create('coffees')[:data]
    assert_equal ['coffees'], conn.list[:data]

    assert !conn.create('coffees')[:data]

    d = conn.about('coffees')[:data]
    assert_equal 'coffees', d['name']
    assert_nil d['precision']

    assert conn.describe('coffees', {:d => 'How much coffee I drank'})[:data]
    d = conn.about('coffees')[:data]
    assert_equal 'How much coffee I drank', d['description']
    assert_nil d['units']

    assert conn.erase('coffees')[:data]
    assert !conn.erase('coffees')[:data]
  end

  def test_002_write
    t = Time.parse("2011-10-26 11:15:44 +0100")

    assert_equal( {'number' => 1, 'stamp' => '1.0', 'insertions' => 1, 'removals' => 0}, conn.insert('coffees', 4, t)[:data])
    assert_equal( {'number' => 2, 'stamp' => '2.0', 'insertions' => 2, 'removals' => 0}, conn.insert('coffees', 2, t + 1)[:data])

    assert_nil conn.remove('coffees', 4, t + 1)[:data]

    assert_equal( {'number' => 2, 'stamp' => '2.0', 'insertions' => 2, 'removals' => 0}, conn.version('coffees')[:data])
    assert_equal( {'number' => 3, 'stamp' => '2.1', 'insertions' => 2, 'removals' => 1}, conn.remove('coffees', 2, t + 1)[:data])
    assert_equal( {'number' => 4, 'stamp' => '3.1', 'insertions' => 3, 'removals' => 1}, conn.insert('coffees', 3, t + 2)[:data])


  end


  def test_003_read
    t = Time.parse("2011-10-26 11:15:44 +0100")
    td = Time.parse("2011-10-26 00:00:00 +0000")

    assert_equal [[t.to_s, 4, {}], [(t+2).to_s, 3, {}]], conn.entries('coffees')[:data]
    assert_equal [[t.to_s, (t+2).to_s],[4, 3]], conn.series('coffees')[:data]

    assert_equal [[(t+2).to_s, 3, {}]], conn.entries('coffees', :limit => 1)[:data]
    assert_equal [[t.to_s, 4, {}]], conn.entries('coffees', :start => 0, :limit => 1)[:data]
    assert_equal [[(t+2).to_s, 3, {}]], conn.entries('coffees', :start => -1)[:data]
    assert_equal [[t.to_s, 4, {}], [(t+2).to_s, 3, {}]], conn.entries('coffees', :from => td)[:data]
    assert_equal [], conn.entries('coffees', :from => td + 84600)[:data]

    assert_equal [[td.to_s, 7, {}]], conn.entries(['coffees', 'total/d'])[:data]
    assert_equal [[td.to_s, 3.5, {}]], conn.entries(['coffees', 'ave/d'])[:data]

    assert_equal({
                   'total' => 7,
                   'count' => 2,
                   'mean' => 3.5,
                   'min' => 3,
                   'max' => 4,
                   'median' => 3.5,
                   'mode' => nil
                 }, conn.stats('coffees')[:data])


    assert_equal( {'number' => 5, 'stamp' => '4.1', 'insertions' => 4, 'removals' => 1}, conn.insert('coffees', 2, t + 4, {:some => 'val'})[:data])

    assert_equal [[2, 1], [3, 1], [4, 1]], conn.distribution('coffees', 1)[:data]
    assert_equal [[0, 0], [2, 2], [4, 1]], conn.distribution('coffees', 2, 0)[:data]

    assert_equal ['some'], conn.properties('coffees')[:data]

    assert_equal 9, conn.headline('coffees', :before => td + 86400)[:data]
    assert_equal 9, conn.headline('coffees', :before => t + 3600, :t => '60m')[:data]
    assert_equal 0, conn.headline('coffees', :before => t + 3600, :t => '59m')[:data]
    assert_equal 4, conn.headline('coffees', :before => t + 3600, :metric => 'max')[:data]

    puts conn.histogram('coffees', 3, 0)[:data]
    puts conn.draw(['coffees', 'total/2s'], :limit => 4)[:data]

    assert_equal( {
                    'direction' => 'down',
                    'gradient' => -1.0,
                    'intercept' => 5.0,
                    'rsquared' => 1.0,
                    'analysis' => 'slr'
                  }, conn.trend(['coffees', 'total/2s'], :limit => 4)[:data])

    #puts conn.get 'coffees', 'entries', {:end => -1}
  end

  def test_004_cleanup
    conn.erase('coffees')
  end


end
