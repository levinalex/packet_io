#!/usr/bin/ruby -w

require 'test/unit'
require 'stringio'
require 'serial_interface'
require 'protocol/rca2006'

class TestSerialInterface < Test::Unit::TestCase
  def setup

    @data_packet = SerialPacket.create { data_format "C*"; header [?:,?D] }
    
    @io_send = StringIO.new
    @io_receive = StringIO.new
    
    @sender = PacketIO.new(SerialProtocol::RCA2006, nil, @io_send)
    @receiver = PacketIO.new(SerialProtocol::RCA2006, @io_receive, nil)
  end
  
  def test_send_packet
    @sender.add_sender(:data => @data_packet).run

    @sender.send_packet :data, ?A, ?B, ?C, ?D, ?E
    @io_send.rewind
    
    assert_equal("\x65\xEB\x00\x00\a:DABCDE\2443",@io_send.read)
  end

  def test_receive_packet
    @io_receive << "\x65\xEB\x00\x00\a:DABCDE\2443"
    @io_receive.rewind

    @receiver.add_receiver(:data => @data_packet) do |packet|
      assert_equal( [?:,?D,?A,?B,?C,?D,?E], packet.data )
    end
    @receiver.run
  end

  def test_timeout
    @receiver.on_receive { |str| @data = str }
    @receiver.run
    
    Thread.new {
      Thread.pass
      @io_receive << "\x65\xEB\x00\x00\a:DABCDE\2443"
      @io_receive.rewind
    }

    assert_equal( nil, @data )
    assert_nothing_raised {
      @receiver.wait_for_packet(1,2)
    }
    assert_equal( ":DABCDE", @data )

    assert_raises(Timeout::Error) {
      @receiver.wait_for_packet(1,1)
    }
  end


end


