module PacketIO::Test
  class MockServer
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
