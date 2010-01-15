module SerialProtocol

  # Serial protocol Roboterclub Aachen 2006
  # http://www.roboterclub.rwth-aachen.de/
  #
  # Packet format:
  #   [0x65, 0xEB, <type:8>, <counter:8>, <length:8>, data:length>, <crc:16>]
  #
  # <type> is one of the following:
  #    0b00000000 --> Data packet, discard on checksum mismatch
  #    0b00011111 --> Data packet, resend on checksum mismatch
  #    0b11100011 --> ACK packet
  #    0b11111100 --> NACK packet
  #
  class RCA2006

    STARTBYTES = "\x65\xeb"
    TYPE = {
      :data_no_crc => 0,
      :data        => 0b00011111,
      :ack         => 0b11100011,
      :nack        => 0b11111100 }

    def initialize(send_callback, receive_callback, options = {})
      @rec_queue = Queue.new
      @state = :first_startbyte
      @send_callback = send_callback
      @receive_callback = receive_callback
    end

    # Set callbacks whenever a packet is sent or received.
    #
    def on_raw_receive(&block)
      @raw_receive_callback = block
    end
    def on_raw_send(&block)
      @raw_send_callback = block
    end

    # Wrap a string into a packet
    #
    # the options-hash can be used to override the default packet format
    #
    def send_packet(data, options = {})
      str = data.to_s
      type = TYPE[ options[:type] || :data_no_crc].chr
      counter = options[:counter] || 0
      checksum = options[:checksum] || ("" << counter << str.length << str).crc_xmodem

      @raw_send_callback.call(type, counter, data, checksum) if @raw_send_callback

      p = "" << STARTBYTES << type << counter << str.length << str << [checksum].pack("S").reverse

      # send the packet, using the callback
      #
      @send_callback.call(p)
    end

    def receive_handler(type, counter, data, checksum)
      @raw_receive_callback.call(type,counter,data,checksum) if @raw_receive_callback

      case type
      when :ack
      when :nack
      when :data
        @receive_callback.call(data)
      when :data_no_crc
        @receive_callback.call(data)
      end
    end

    # Big and ugly state machine that does most of the work
    #
    def add_char_to_packet(char)
      @state = :first_checksum if (@state == 0)
      case @state
      when :first_startbyte
        @data = ""
        @state = ((char == STARTBYTES[0]) ? :second_startbyte : :first_startbyte)
      when :second_startbyte
        @state = (char == STARTBYTES[1]) ? :type :
          # special case: first startbyte is repeated
          (char == STARTBYTES[0] ? :second_startbyte : :first_startbyte)
      when :type
        @type = TYPE.invert[char]
        @state = :counter
      when :counter
        @counter = char
        @state = :length
      when :length
        @length = char
        @state = @length
      when Integer
        @data << char
        @state -= 1
      when :first_checksum
        @checksum = (char << 8)
        @state = :second_checksum
      when :second_checksum
        @checksum = @checksum + char
        @state = :first_startbyte

        crc = ("" << @counter << @length << @data).crc_xmodem
          # received a valid packet

        if @type == :data || @type == :data_no_crc
          if @checksum == crc

            # send ACK
            send_packet(nil, :type => :ack, :counter => @counter)
            receive_handler(@type, @counter, @data,@checksum)
          else
            # send NACK and discard packet
            send_packet(nil, :type => :nack, :counter => @counter)
            raise ChecksumMismatch, "ChecksumMismatch, expected #{crc}, was #{@checksum}"
          end
        else
          # the packet is ACK, NACK or unknown, call receive-handler
          # data may be mangled since the checksum is not checked
          #
          receive_handler(@type, @counter, @data, @checksum)
        end
      end
    end
  end

  class RCA2006Simple < RCA2006
    def initialize(send_callback, receive_callback, options = {})
      @type = :data_no_crc
      @counter = 0
      super
    end

    # Wrap a string into a packet
    #
    # the options-hash can be used to override the default packet format
    #
    def send_packet(data, options = {})
      str = data.to_s
      checksum = options[:checksum] || ("" << str.length << str).crc_xmodem

      @raw_send_callback.call(:data_no_crc, 0, data, checksum) if @raw_send_callback

      p = "" << STARTBYTES << str.length << str << [checksum].pack("S").reverse

      # send the packet, using the callback
      #
      @send_callback.call(p)
    end

    # Big and ugly state machine that does most of the work
    #
    def add_char_to_packet(char)
      @state = :first_checksum if (@state == 0)
      case @state
      when :first_startbyte
        @data = ""
        @state = ((char == STARTBYTES[0]) ? :second_startbyte : :first_startbyte)
      when :second_startbyte
        @state = (char == STARTBYTES[1]) ? :length :
          # special case: first startbyte is repeated
          (char == STARTBYTES[0] ? :second_startbyte : :first_startbyte)
      when :length
        @length = char
        @state = @length
      when Integer
        @data << char
        @state -= 1
      when :first_checksum
        @checksum = (char << 8)
        @state = :second_checksum
      when :second_checksum
        @checksum = @checksum + char
        @state = :first_startbyte

        crc = ("" << @length << @data).crc_xmodem
          # received a valid packet

        if @type == :data || @type == :data_no_crc
          if @checksum == crc

            receive_handler(@type, @counter, @data,@checksum)
          else
            # send NACK and discard packet
            raise ChecksumMismatch, "ChecksumMismatch, expected #{crc}, was #{@checksum}"
          end
        else
          # the packet is ACK, NACK or unknown, call receive-handler
          # data may be mangled since the checksum is not checked
          #
          receive_handler(@type, @counter, @data, @checksum)
        end
      end
    end
  end
end

