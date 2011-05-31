# packet_io

    by Levin Alexander
    http://levinalex.net/

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

## LICENSE:

(The MIT License)

Copyright (c) 2006-2011 Levin Alexander

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
