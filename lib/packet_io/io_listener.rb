module PacketIO

  # a chainable IO-Listener that provides two methods:
  #
  # {#on_data} ::
  #   a callback that is called whenever a message is received
  # {#write} ::
  #   can be called so send messages to the underlying IO
  #
  # when overriding this class, you need to implement two methods:
  #
  # {#receive} ::
  #   is called from an underlying IO whenever a message is received
  #   the message can be handled.  Call {#forward} to propagate
  #
  # {#write} ::
  #   transform/encode a message before sending it. Call +super+ to propagate
  #
  # See {LineBasedProtocol} for a toy implementation which strips
  # newlines and only forwards complete lines.
  #
  class Base

    # @param [Base, #on_data] read data source
    # @param [Base, IO, #write] write object where messages are written to
    #
    def initialize(read, write = read)
      @reader, @writer = read, write
      @on_data = nil
      @reader.on_data { |*data| receive(*data) } if @reader.respond_to?(:on_data)
    end

    # register a block, to be run whenever the protocol implementation
    # receives data (by calling {#forward})
    #
    # this is used to chain protocol layers together
    #
    # @return [self]
    # @yield [*args] called whenever the protocol implementaion calls {#forward}
    # @yieldreturn [nil]
    #
    def on_data(&block)
      @on_data = block
      self
    end

    # @see #write
    #
    def <<(*args)
      write(*args)
    end

    # write data to underlying interface. override if data needs to be preprocessed
    #
    def write(*args)
      @writer.<<(*args) if @writer
    end


    protected

    # override this method to handle data received from an underlying interface, for
    # example splitting it into messages or only passing on complete lines
    # (see {LineBasedProtocol#receive} for an example)
    #
    # call {#forward} to pass it on to higher levels
    #
    # @return [nil]
    #
    def receive(*data)
      forward(*data)
    end

    def forward(*data)
      @on_data.call(*data) if @on_data
    end
  end


  class LineBasedProtocol < Base
    def initialize(*args)
      super
      @buffer = StringScanner.new("")
    end

    # strip newlines from received data and pass on complete lines
    #
    # @param [String] data
    #
    def receive(data)
      @buffer.concat(data)
      while s = @buffer.scan(/.*?\n/)
        forward(s.strip)
      end
      nil
    end

    # add a newline to data and pass it on
    # @param [String] data
    #
    def write(data)
      super(data + "\n")
    end
  end

  class IOListener < Base
    def run!
      while not @reader.eof?
        str = @reader.readpartial(4096)
        forward(str)
      end
    end
  end
end

