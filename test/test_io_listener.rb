require 'helper'

class TestIOListener < Test::Unit::TestCase
  context "a server" do
    setup do
      @device, client_read, client_write = PacketIO::Test::MockServer.build
      @server = PacketIO::IOListener.new(client_read, client_write)
      @protocol = PacketIO::LineBasedProtocol.new(@server)
    end

    should "exist" do
      assert_not_nil @server
    end

    should "yield packets written to it" do
      @packets = []
      @protocol.on_data { |packet| @packets << packet }

      @device.write("fo").wait.write("o\n").wait.write("bar\n").eof
      @server.run!

      assert_equal ["foo", "bar"], @packets
    end

    should "send data" do
      @protocol << "hello world"
      data = @device.read_all
      assert_equal "hello world\n", data
    end
  end
end
