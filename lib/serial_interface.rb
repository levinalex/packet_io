#!usr/bin/ruby -w

require 'thread'
require 'enumerator'
require 'timeout'

require File.join(File.dirname(__FILE__),'serial_packet.rb')

# FIXME: this should probably be put in a separate file
#
class String
  def crc_xmodem
    self.to_enum(:each_byte).inject(0) { |crc,byte|
      crc = (crc ^ (byte << 8)) % 0x10000
      8.times {
        crc <<= 1
        crc ^= 0x1021 if crc[16] == 1
      }
      crc
    } % 0x10000
  end
end

module SerialInterface
  VERSION = '0.3.0'
end

# PacketIO is used to wrap data in packets and send them
# over a serial port or some other IO
#
class PacketIO
  attr_accessor :protocol_handler

  # Takes two IO-Objects (uses "readchar" and "<<") to read and write from
  #
  def initialize(protocol, read, write = read, options = {})
    @read, @write = read, write
    @on_receive = nil

    # Hashes contain SerialPackets that can be sent and received
    #
    @sendable_packets = {}
    @receivable_packets = []

    @waiting_threads = []

    @protocol_handler = protocol.new(method(:send_callback),method(:receive_callback), options)

    # Create the receiver thread, but do not start it yet
    #
    @receiver_thread = Thread.new do
      Thread.abort_on_exception = true
      Thread.stop

      loop do
        begin
          char = @read.readchar
          @protocol_handler.add_char_to_packet(char) if char
        rescue EOFError
          Thread.pass # there is currently nothing to read
        end
      end if @read  # no need to loop, if there is nothing to read from
    end
  end

  # suspends the current thread, until +num+ packets have been received
  # the thread will be resumed after all callbacks were called
  #
  def wait_for_packet(num_packets = 1, timeout = 10)
    begin
      @waiting_threads << {:num => num_packets, :thread => Thread.current}
      sleep timeout
      raise Timeout::Error, "Timeout"
    rescue SerialProtocol::PacketReceived => e
    ensure
      # delete all occurrences of the current thread from the list of waiting threads,
      # as we are obviously not waiting anymore
      @waiting_threads.delete_if { |h| h[:thread] == Thread.current }
    end
  end

  # The block given to this method is called with every received string
  #
  def on_receive(&block)
    @on_receive = block
  end

  def add_sender(hash = {})
    hash.each { |k,v|
      @sendable_packets[k] = v
    }
    self
  end

  # Add a type of packet, that should be checked for in the interface
  #
  # If a packet is received
  #
  def add_receiver(hash = {}, &block)
    hash.each { |k,v|
      @receivable_packets << {:packet => v, :block => block}
    }
    self
  end

  # Data to be wrapped in a packet
  #
  # there are different ways of using this method:
  #
  # send_packet(sym, *data)
  # send_packet(sym, options = {}, *data)
  #   looks for a packet-class named sym and creates a new instance of this type
  #   of packet
  #   the optional hash is passed to the protocol layer
  #
  # send_packet(string, options = {})
  #   sends a raw string
  #   the optional hash is passed to the protocol layer
  #
  #
  def send_packet(data, *args)
    options = (Hash === args.first) ? options = args.shift : {}
    data = (Symbol === data) ? @sendable_packets[data].new(*args) : data

    @protocol_handler.send_packet(data.to_str, options)
    self
  end

  # starts the receiver thread
  #
  def run
    @receiver_thread.wakeup
    self
  end

  def join
    @receiver_thread.join
    self
  end

  private

  # this method is called, when a packet should be sent
  #
  def send_callback(str)
    @write << str if @write
  end

  def receive_callback(packet_str)
    # call the on_receive event handler for every packet
    @on_receive.call(packet_str) if @on_receive

    # try to match the packet-string against the list of known packets
    @receivable_packets.each { |h|
      if h[:packet].matches?(packet_str)
        h[:block].call( h[:packet].from_str(packet_str) )
      end
    }

    # check if there are threads to wake up
    #
    @waiting_threads.each { |h|
      h[:num] -= 1 # decrease the number of packets, this thread waits for
      h[:thread].raise SerialProtocol::PacketReceived if h[:num] == 0
    }
  end

end

module SerialProtocol
  class ChecksumMismatch < RuntimeError
  end

  class PacketReceived < Exception
  end
end

module SerialProtocol

  # The classes in this section implement wrappers for specific protocols
  # to be used on a serial port
  #
  # They need to implement the following methods:
  #
  #  initialize(send_callback, receive_callback, option_hash = {})
  #    creates a new instance of the protocol object
  #    it gets two methods to talk back to the interface
  #    class
  #
  #  add_char_to_packet(char)
  #    called for each char, that is received.
  #
  #  send_packet(data, options)
  #    called from the application to send a packet.  The class is
  #    expected to wrap the data in the specific packet format string and in
  #    turn call send_callback(data_str) which will take care of the actual
  #    transmission
  #
  # A protocol class is expected to call receive_callback(packet_str) as soon
  # as a valid packet is received
  #


  class LineBased
    def initialize(send_callback, receive_callback, options = {})
      @send_callback, @receive_callback = send_callback, receive_callback
      @packet_buffer = ""
    end

    def add_char_to_packet(char)
      if /\n/ === char.chr
        @receive_callback.call(@receive_buffer)
        @packet_buffer = ""
      else
        @packet_buffer << char
      end
    end

    def send_packet(data, options = {})
      @send_callback.call(data + "\n")
    end
  end
end

