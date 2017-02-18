# packet_io

    by Levin Alexander
    http://levinalex.net/

[![Build Status](https://travis-ci.org/levinalex/packet_io.svg?branch=master)](https://travis-ci.org/levinalex/packet_io)


## DESCRIPTION:

packet_io is a small library that makes it easy
to define packet based protocols over a serial link (RS232) in a
declarative fashion.

## SYNOPSIS:

    require 'packet_io'

    # define your protocol handler, inheriting from PacketIO::Base
    #
    # override `read` and `write` to implement your functionality
    #
    # this is a simple protocol handler that does nothing.
    #
    # see {PacketIO::LineBasedProtocol} for another trivial example
    #
    class MyNOPProtocol < PacketIO::Base
      def receive(packet)
        forward(packet)
      end

      def write(data)
        super(packet)
      end
    end

    # use your protocol. It is possible to stack multiple protocol
    # layers on top of each other
    #
    stream = PacketIO.IOListener(File.open("/dev/ttyUSB0"))
    line_based = PacketIO::LineBasedProtocol.new(stream)
    my_protocol = MyNOPProtocol.new(line_based)


    stream.run!

## INSTALL:

    gem install packet_io

