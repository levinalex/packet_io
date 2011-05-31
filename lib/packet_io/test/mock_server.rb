module PacketIO::Test
  class MockServer

    # create a new server and wire it up with a bidirectional pipe
    #
    def self.build
      client_read, server_write = IO.pipe # Server -> Client
      server_read, client_write = IO.pipe # Client -> Server

      @device = new(server_read, server_write)
      return @device, client_read, client_write
    end

    def initialize(read, write)
      @read, @write = read, write
      @queue = Queue.new
      @thread = Thread.new do
        parse_commands
      end
    end

    def write(string)
      @queue.push [:write, string]
      self
    end

    def read_all
      @read.readpartial(4096)
    end

    def wait(seconds = 0.02)
      @queue.push [:wait, seconds]
      self
    end

    def eof
      @queue.push [:close]
    end


    private

    def parse_commands
      loop do
        action, data = @queue.pop

        case action
        when :close
          @write.close
          break
        when :write
          @write.write(data)
          @write.flush
        when :wait
          sleep data
        end
      end
    end
  end
end
