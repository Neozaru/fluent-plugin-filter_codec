# coding: utf-8
require "base64"
require "fluent/plugin/filter"
require "fluent/plugin/filter_codec_support"

module Fluent::Plugin
  class CodecFilter < Filter
    include Fluent::FilterCodecSupport

    Fluent::Plugin.register_filter('codec', self)

    config_param :field, :string, :default => nil
    config_param :output_field, :string, :default => nil
    config_param :codec, :string, :default => nil
    config_param :error_value, :string, :default => ""


    def configure(conf)
      super

      # Put new functions here
      @codec_functions = {
        'base64-decode' => method(:base64_decode),
        'base64-encode' => method(:base64_encode),
        'urlsafe64-decode' => method(:urlsafe64_decode),
        'urlsafe64-encode' => method(:urlsafe64_encode)
      }

      if (field.nil? || codec.nil?)
        raise Fluent::ConfigError, "filter_codec: Both 'field', and 'codec' are required to be set."
      end

      if (@codec_functions[codec].nil?)
        raise Fluent::ConfigError, "filter_codec: Unknown codec : " + codec
      end

      @output_field = output_field || field
    end

    def filter(tag, time, record)
      value_in = record[@field]
      return nil if (value_in.nil?)

      record[@output_field] = process_filter(value_in, @codec) || value_in
      record
    end
  end
end
