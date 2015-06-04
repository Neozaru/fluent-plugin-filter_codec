# fluent-plugin-filter_codec

Fluentd output plugin which converts a field in the record.
Codec can be:
 'base64-encode' and 'base64-decode' see RFC 4648
 'urlsafe64-encode' and 'urlsafe64-decode' replacing '+/' by '-_' and making '=' padding optional

## Usage

```
<match test>
    type filter_codec
    add_tag_prefix decoded.
    codec base64-decode
    field key1
    output_field key2
</match>
```

Example of records :
```
{
    'key1' => "Tmljb2xhcyBDYWdl",
    'foo' => "bar"
}
```
... will output (unchanged) :
```
{
    'key1' => "Nicolas Cage",
    'foo' => "bar"
}
```

You can omit 'output_field' so 'field' value will be replaced by output value.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/fluent-plugin-filter_codec/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
