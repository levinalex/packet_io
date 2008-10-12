#!usr/bin/ruby

require 'rubygems'
require 'traits' # from http://www.codeforpeople.com/lib/ruby/traits/traits-0.8.1/

# SerialPacket is used to define the format of Packets that
# can be sent and received over a serial link
#
# they are essentially a description how to create a string
# representation from an array
#
# a packet has the following properties:
#
#   data_format(string)
#      this is a string that is passed to 'pack' and 'unpack'
#
#   header_format(string)   
#      this is the format of the header of received packets
#      this property is used with SerialPacket.matches?
#
#   header_data
#      an array that is used to decide if a given String is
#      
module SerialPacketModule
  def self.included(other)
    other.class_eval do 

      def initialize_from_packet(str)
        self.data = str.unpack(self.class.data_format)      
      end
      
      def initialize(*d)
        self.data = d
      end

      def to_str
        self.class.header_str << self.data.pack(self.class.data_format)
      end
      
      class << self

        # a packet can only be sent if it has a header
        #
        def sendable?
          (self.header && self.header_format) ? true : false
        end

        def header_str
          if sendable?
            h = self.header || []
            h.pack(self.header_format) || ""
          else
            ""
          end
        end
        
        # a packet can only be received, if it has a filter-expression
        def receiveable?
          defined? header_format and header_filter
        end

        # checks if some string conforms to the format of this packet
        #
        # this is tested by matching the packet "header" against the 
        # provided filter-expression
        #
        def matches?(str)
          header = str.unpack(header_format)
          filter = self.header_filter || []
          filter.zip(header) { |f,a| return false unless f === a }
          return true
        end

        def from_str(str) #:nodoc:
          p = self.allocate
          p.initialize_from_packet(str)
          p
        end

        def create(&block)
          klass = Class.new(self)
          klass.instance_eval(&block) if block
          return klass    
        end
      end
    end
  end
end

class SerialPacket
  include SerialPacketModule

  class_trait :data_format => "C*"   # packet defaults to an array of bytes
  class_trait :header_format => "CC" # it has a 2-byte header
  class_trait :header_filter => ""   # it will react to every byte
  class_trait :header => nil # there is no default header
                             # this should be "[]" but arrays do not work
                             # in traits
  traits :data => nil

  # to store custom data in the packat, override
  # one or more of the following methods:
  #
  # initialize_from_packet(str)
  #   populate instance variables with data
  #
  # to_str
  #   return the string that is sent over the wire
  #
  # matches?(str)
  #   default implementation uses +header_format+ and +header+
  #   to determine if a given string matches a packet

end

