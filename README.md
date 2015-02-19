Example :

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