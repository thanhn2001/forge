require 'ostruct'

module Forge
  class Config < OpenStruct

    def merge!(options)
      raise ArgumentError unless options.is_a?(Hash) || options.is_a(OpenStruct)

      options.each_pair do |key, value|
        self.send("#{ key }=", value)
      end
    end

  end
end
