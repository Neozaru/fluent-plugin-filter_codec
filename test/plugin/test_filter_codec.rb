# coding: utf-8

require 'test_helper'
require 'fluent/plugin/filter_codec'

class CodecFilterTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf, tag = 'test')
    Fluent::Test::FilterTestDriver.new(
      Fluent::CodecFilter, tag
    ).configure(conf)
  end

  def test_configure_on_success

    # All set
    d = create_driver(%[
      field key1
      output_field key2
      codec base64-decode
      error_value foo
    ])

    assert_equal 'key1',    d.instance.field
    assert_equal 'key2', d.instance.output_field
    assert_equal 'base64-decode', d.instance.codec
    assert_equal 'foo', d.instance.error_value

    # output_field and error_value missing
    d = create_driver(%[
      field key1
      codec base64-decode
    ])

    assert_equal 'key1',    d.instance.field
    assert_equal 'key1', d.instance.output_field
    assert_equal 'base64-decode', d.instance.codec
    assert_equal '', d.instance.error_value

  end

  def test_configure_on_failure
    # when mandatory keys not set
    assert_raise(Fluent::ConfigError) do
      create_driver(%[
        blah blah
      ])
    end

    # when 'field' is missing
    assert_raise(Fluent::ConfigError) do
      create_driver(%[
      output_field key2
      codec base64-decode
    ])
    end

    # when unknown codec
    assert_raise(Fluent::ConfigError) do
      create_driver(%[
      field key1
      output_field key2
      codec unknown-codec
    ])
    end

  end

  def test_emit_with_base64_decode
    d = create_driver(%[
      field key1
      output_field key2
      codec base64-decode
    ])

    record = {
      'key1' => "Tmljb2xhcyBDYWdl",
      'foo' => "bar"
    }

    d.run { d.emit(record) }
    emits = d.filtered_as_array

    assert_equal 1,           emits.count
    assert_equal 'test', emits[0][0]
    assert_equal 'Nicolas Cage',emits[0][2]['key2']
  end

  def test_emit_with_base64_decode_and_no_output
    d = create_driver(%[
      field key1
      codec base64-decode
    ])

    record = {
      'key1' => "Tmljb2xhcyBDYWdl",
      'foo' => "bar"
    }

    d.run { d.emit(record) }
    emits = d.filtered_as_array

    assert_equal 1,           emits.count
    assert_equal 'test', emits[0][0]
    assert_equal 'Nicolas Cage',emits[0][2]['key1']
  end

  def test_emit_with_base64_encode
    d = create_driver(%[
      field key1
      output_field key2
      codec base64-encode
    ])

    record = {
      'key1' => "Nicolas Cage",
      'foo' => "bar"
    }

    d.run { d.emit(record) }
    emits = d.filtered_as_array

    assert_equal 1,           emits.count
    assert_equal 'test', emits[0][0]
    assert_equal 'Tmljb2xhcyBDYWdl',emits[0][2]['key2']
  end

  def test_emit_with_base64_decode_error_not_set
    d = create_driver(%[
      field key1
      output_field key2
      codec base64-decode
    ])

    record = {
      'key1' => "YmFkdmFsdWU",
      'foo' => "bar"
    }

    d.run { d.emit(record) }
    emits = d.filtered_as_array

    assert_equal 1,           emits.count
    assert_equal 'test', emits[0][0]
    assert_equal '',emits[0][2]['key2']
  end

  def test_emit_with_base64_decode_error_set
    d = create_driver(%[
      field key1
      output_field key2
      codec base64-decode
      error_value foo
    ])

    record = {
      'key1' => "YmFkdmFsdWU",
      'foo' => "bar"
    }

    d.run { d.emit(record) }
    emits = d.filtered_as_array

    assert_equal 1,           emits.count
    assert_equal 'test', emits[0][0]
    assert_equal 'foo',emits[0][2]['key2']
  end

  data("base" => {"key1" => "Tmk-b2w_c8K_Q8O-Zy_CqSBDYWdl",
                  "expected" => "Ni>ol?s¿Cþg/© Cage".force_encoding("ASCII-8BIT")},
       "remote the last character" => {"key1" => "Tmk-b2w_c8K_Q8O-Zy_CqSBDYWc",
                                       "expected" => "Ni>ol?s¿Cþg/© Cag".force_encoding("ASCII-8BIT")},
       "remote the last two characters" => {"key1" => "Tmk-b2w_c8K_Q8O-Zy_CqSBDYQ",
                                            "expected" => "Ni>ol?s¿Cþg/© Ca".force_encoding("ASCII-8BIT")}
      )
  def test_emit_with_urlsafe64_decode(data)
    d = create_driver(%[
      field key1
      output_field key2
      codec urlsafe64-decode
    ])

    record = {
      'key1' => data["key1"],
      'foo' => "bar"
    }
    expect = "Ni>ol?s¿Cþg/© Cage".force_encoding("ASCII-8BIT")

    d.run { d.emit(record) }
    emits = d.filtered_as_array

    assert_equal 1,           emits.count
    assert_equal 'test', emits[0][0]
    assert_equal data["expected"],emits[0][2]['key2']
  end

  data("base" => {"key1" => "Ni>ol?s¿Cþg/© Cage".force_encoding("ASCII-8BIT"),
                  "expected" => "Tmk-b2w_c8K_Q8O-Zy_CqSBDYWdl"},
       "remote the last character" => {"key1" => "Ni>ol?s¿Cþg/© Cag".force_encoding("ASCII-8BIT"),
                                       "expected" => "Tmk-b2w_c8K_Q8O-Zy_CqSBDYWc"},
       "remote the last two characters" => {"key1" => "Ni>ol?s¿Cþg/© Ca".force_encoding("ASCII-8BIT"),
                                           "expected" => "Tmk-b2w_c8K_Q8O-Zy_CqSBDYQ"}
      )
  def test_emit_with_urlsafe64_encode(data)
    d = create_driver(%[
      field key1
      output_field key2
      codec urlsafe64-encode
    ])

    record = {
      'key1' => data["key1"],
      'foo' => "bar"
    }

    d.run { d.emit(record) }
    emits = d.filtered_as_array

    assert_equal 1,           emits.count
    assert_equal 'test', emits[0][0]
    assert_equal data["expected"],emits[0][2]['key2']
  end

end
