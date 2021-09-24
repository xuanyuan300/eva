unit module Factory::Aliyun::VPC;

proto aliyun_vpc_spec(|) is export { * }

multi sub aliyun_vpc_spec("name", Str $name) {
  name => $name
}


multi sub aliyun_vpc_spec("values", Positional:D $values) {
  my %res;
  for $values.hash.kv -> $k, $v {
    %res.push(aliyun_vpc_spec($k, $v).hash)
  }

  %res;
}

multi sub aliyun_vpc_spec("values", Associative:D $values) {
  my %res;
  for $values.kv -> $k, $v {
    %res.push(aliyun_vpc_spec($k, $v).hash)
  }
  %res
}

multi sub aliyun_vpc_spec("cidr", Str $val) {
  cidr_block => $val;
}

multi sub aliyun_vpc_spec("start", Str $name) {
  qq[
resource "alicloud_vpc" "$name" \{\n
]
}

multi sub aliyun_vpc_spec("end") {
  Q[}]
}

multi sub aliyun_vpc_spec("sieffect", Str $name) {
  qq[\$\{alicloud_vpc.$name.id\}]
}

multi sub aliyun_vpc_spec(|other) {
  []
}