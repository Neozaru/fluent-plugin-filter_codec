module Fluent
  module FilterCodecSupport
    def process_filter(value, codec)
      return @codec_functions[codec].call(value)
    rescue
      return @error_value
    end

    def base64_decode(value)
      return Base64.strict_decode64(value)
    end

    def base64_encode(value)
      return Base64.strict_encode64(value)
    end

    def add_one_padding(str)
      return (0 != str.length % 4) ? str + '=' : str
    end

    def urlsafe64_decode(value)
      # Add up to 2 '=' padding
      return Base64.urlsafe_decode64(add_one_padding(add_one_padding(value)))
    end

    def urlsafe64_encode(value)
      # Remove up to 2 '=' padding
      return Base64.urlsafe_encode64(value).chomp('=').chomp('=')
    end
  end
end
