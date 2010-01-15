#!/usr/bin/ruby -w

require 'test/unit'
require 'tempfile'

require 'serial_packet'

class TestPacketFilter < Test::Unit::TestCase
  def setup
    @default_packet_format = SerialPacket.create
    @default_packet = @default_packet_format.new
  end

  def test_instantiate_empty_packet
    assert_equal([], @default_packet.data)
    assert_equal("", @default_packet.to_str)
  end

  def test_instantiate_basic_packet
    p = @default_packet_format.new ?A,?B,?C

    assert_equal([?A,?B,?C], p.data)
    assert_equal("ABC", p.to_str)
  end

  def test_packet_format_string
    my_packet = SerialPacket.create { data_format "A*" }
    p = my_packet.new "Hallo"

    assert_equal(["Hallo"], p.data)
    assert_equal("Hallo", p.to_str)
  end

  def test_packet_create_from_str
    p = @default_packet_format.from_str("bar")

    assert_equal([?b,?a,?r], p.data)
  end

  def test_packet_header
    my_packet = SerialPacket.create { header_format "CC"; header [?a,?b] }

    assert_equal([?a,?b], my_packet.header)
  end

  def test_match
    empty = SerialPacket.create
    numbers = SerialPacket.create { header_format "ss"; header_filter [-1,32767] }
    regex = SerialPacket.create{ header_format "a*"; header_filter [/foo/] }
    mixed = SerialPacket.create { header_format "@5C @2C"; header_filter [?X,?Y] }

    assert_equal true, empty.matches?("abcde")

    assert_equal(true, numbers.matches?("\xff\xff\xff\x7f"))
    assert_equal(false, numbers.matches?("\xff\xff\xff\x80"))
    assert_equal(false, numbers.matches?("Packet with foo in it"))
    assert_equal(true, regex.matches?("Packet with foo in it"))
    assert_equal(false, regex.matches?("Packet with bar in it"))
    assert_equal(false, regex.matches?("\xff\xff\xff\x80"))
    assert_equal true, mixed.matches?("__Y__X___")
    assert_equal false, mixed.matches?("YYYYYYY")
  end

  class Position < SerialPacket
      header_format "CC"
      header [?P,?p]
      data_format "SS"
  end

  def test_position_packet
    p = Position.new 1, -1
    assert_equal("Pp\001\000\xff\xff", p.to_str)
  end
end
