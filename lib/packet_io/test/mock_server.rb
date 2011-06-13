require 'thread'

module PacketIO::Test

  # a threaded reader that simulates a remote server to help testing io_listener
  #
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
      @write_queue = Queue.new

      @writer = Thread.new do
        parse_commands
      end
    end

    def write(string)
      @write_queue.push [:write, string]
      self
    end

    def read_all
      @read.readpartial(4096)
    end

    def wait(seconds = 0.02)
      @write_queue.push [:wait, seconds]
      self
    end

    def eof
      @write_queue.push [:close]
    end


    private

    def parse_commands
      loop do
        action, data = @write_queue.pop

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
