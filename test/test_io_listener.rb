require 'minitest/autorun'

require 'packet_io'
require 'packet_io/test/mock_server'

describe "a server" do
  before do
    @device, client_read, client_write = PacketIO::Test::MockServer.build
    @server = PacketIO::IOListener.new(client_read, client_write)
    @protocol = PacketIO::LineBasedProtocol.new(@server)
  end

  it "should exist" do
    assert @server
  end

  it "should yield packets written to it" do
    @packets = []
    @protocol.on_data { |packet| @packets << packet }

    @device.write("fo").wait.write("o\n").wait.write("bar\n").eof
    @server.run!

    assert_equal ["foo", "bar"], @packets
  end

  it "should send data" do
    @protocol << "hello world"
    data = @device.read_all
    assert_equal "hello world\n", data
  end
end
