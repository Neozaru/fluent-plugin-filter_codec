# coding: utf-8
require "base64"

module Fluent
  class FilterCodecOutput < Output
    include Fluent::HandleTagNameMixin

    Fluent::Plugin.register_output('filter_codec', self)

    config_param :field, :string, :default => nil
    config_param :output_field, :string, :default => nil
    config_param :codec, :string, :default => nil
    config_param :error_value, :string, :default => ""


    def configure(conf)
      super

      # Put new functions here
      @codec_functions = {
        'base64-decode' => method(:base64_decode),
        'base64-encode' => method(:base64_encode)
      }

      if (field.nil? || codec.nil?) 
        raise ConfigError, "filter_codec: Both 'field', and 'codec' are required to be set."
      end

      if (@codec_functions[codec].nil?)
        raise ConfigError, "filter_codec: Unknown codec : " + codec
      end

      @field = field
      @codec = codec
      @output_field = output_field || field
      @error_value = error_value

    end

    def emit(tag, es, chain)
      es.each { |time, record|
        t = tag.dup
        filter_record(t, time, record)
        Engine.emit(t, time, record)
      }

      chain.next
    end

    def filter_record(tag, time, record)
      super(tag, time, record)
      value_in = record[@field]
      if (value_in.nil?)
        return
      end

      record[@output_field] = process(value_in, @codec) || value_in
    end

    private
    def process(value, codec)
      return @codec_functions[codec].call(value)

      return value
    rescue
      return @error_value
    end

    def base64_decode(value)
      return Base64.strict_decode64(value)
    end

    def base64_encode(value)
      return Base64.strict_encode64(value)
    end

  end
end
