# coding: utf-8

require 'test_helper'
require 'fluent/plugin/out_filter_codec'

class FilterCodecOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf, tag = 'test')
    Fluent::Test::OutputTestDriver.new(
      Fluent::FilterCodecOutput, tag
    ).configure(conf)
  end

  def test_configure_on_success

    # All set
    d = create_driver(%[
      add_tag_prefix decoded.
      field key1
      output_field key2
      codec base64-decode
      error_value foo
    ])

    assert_equal 'decoded.', d.instance.add_tag_prefix
    assert_equal 'key1',    d.instance.field
    assert_equal 'key2', d.instance.output_field
    assert_equal 'base64-decode', d.instance.codec
    assert_equal 'foo', d.instance.error_value

    # output_field and error_value missing
    d = create_driver(%[
      add_tag_prefix decoded.
      field key1
      codec base64-decode
    ])

    assert_equal 'decoded.', d.instance.add_tag_prefix
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
      add_tag_prefix decoded.
      output_field key2
      codec base64-decode
    ])
    end

    # when unknown codec
    assert_raise(Fluent::ConfigError) do
      create_driver(%[
      add_tag_prefix decoded.
      field key1
      output_field key2
      codec unknown-codec
    ])
    end

  end

  def test_emit_with_base64_decode
    d = create_driver(%[
      add_tag_prefix decoded.
      field key1
      output_field key2
      codec base64-decode
    ])

    record = {
      'key1' => "Tmljb2xhcyBDYWdl",
      'foo' => "bar"
    }

    d.run { d.emit(record) }
    emits = d.emits

    assert_equal 1,           emits.count
    assert_equal 'decoded.test', emits[0][0]
    assert_equal 'Nicolas Cage',emits[0][2]['key2']
  end

  def test_emit_with_base64_decode_and_no_output
    d = create_driver(%[
      add_tag_prefix decoded.
      field key1
      codec base64-decode
    ])

    record = {
      'key1' => "Tmljb2xhcyBDYWdl",
      'foo' => "bar"
    }

    d.run { d.emit(record) }
    emits = d.emits

    assert_equal 1,           emits.count
    assert_equal 'decoded.test', emits[0][0]
    assert_equal 'Nicolas Cage',emits[0][2]['key1']
  end

  def test_emit_with_base64_encode
    d = create_driver(%[
      add_tag_prefix encoded.
      field key1
      output_field key2
      codec base64-encode
    ])

    record = {
      'key1' => "Nicolas Cage",
      'foo' => "bar"
    }

    d.run { d.emit(record) }
    emits = d.emits

    assert_equal 1,           emits.count
    assert_equal 'encoded.test', emits[0][0]
    assert_equal 'Tmljb2xhcyBDYWdl',emits[0][2]['key2']
  end

  def test_emit_with_base64_decode_error_not_set
    d = create_driver(%[
      add_tag_prefix encoded.
      field key1
      output_field key2
      codec base64-decode
    ])

    record = {
      'key1' => "YmFkdmFsdWU",
      'foo' => "bar"
    }

    d.run { d.emit(record) }
    emits = d.emits

    assert_equal 1,           emits.count
    assert_equal 'encoded.test', emits[0][0]
    assert_equal '',emits[0][2]['key2']
  end

  def test_emit_with_base64_decode_error_set
    d = create_driver(%[
      add_tag_prefix encoded.
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
    emits = d.emits

    assert_equal 1,           emits.count
    assert_equal 'encoded.test', emits[0][0]
    assert_equal 'foo',emits[0][2]['key2']
  end

end
