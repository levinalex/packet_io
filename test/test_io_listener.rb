require 'helper'

class TestIOListener < Test::Unit::TestCase
  context "a server" do
    setup do
      r1, w1 = IO.pipe # Server -> Client
      r2, w2 = IO.pipe # Client -> Server

      @server = PacketIO::IOListener.new(r1, w2)
      @protocol = PacketIO::LineBasedProtocol.new(@server)
      @device = PacketIO::Test::MockServer.new(r2, w1)
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
