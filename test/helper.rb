require 'test/unit'
require 'shoulda'
require 'mocha'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'packet_io'
require 'packet_io/test/mock_server'

class Test::Unit::TestCase
end

