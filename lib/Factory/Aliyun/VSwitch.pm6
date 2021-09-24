unit module Factory::Aliyun::VSwitch;

proto aliyun_vswitch_spec(|) is export { * }

#{bind => vpc.id, name => test-subnet, plat => aliyun, resource_type => network_subnet, values => cidr => 10.0.0.0/24, where => az => bj}
multi sub aliyun_vswitch_spec("name", Str $name) {
  name => $name
}

multi sub aliyun_vswitch_spec("bind", Str $val) {
  vpc_id => $val
}

multi sub aliyun_vswitch_spec("where", Associative:D $val) {
  my %res;
  for $val.kv -> $k, $v {
    %res.push(aliyun_vswitch_spec($k, $v).hash)
  }
  %res
}

multi sub aliyun_vswitch_spec("az", Str $val) {
  availability_zone => $val
}

multi sub aliyun_vswitch_spec("values", Positional:D $values) {
  my %res;
  for $values.hash.kv -> $k, $v {
    %res.push(aliyun_vswitch_spec($k, $v).hash)
  }

  %res;
}

multi sub aliyun_vswitch_spec("values", Associative:D $values) {
  my %res;
  for $values.kv -> $k, $v {
    %res.push(aliyun_vswitch_spec($k, $v).hash)
  }
  %res
}

multi sub aliyun_vswitch_spec("cidr", Str $val) {
  cidr_block => $val;
}

multi sub aliyun_vswitch_spec("start", Str $name) {
  qq[
resource "alicloud_vswitch" "$name" \{\n
]
}

multi sub aliyun_vswitch_spec("end") {
  Q[}]
}

multi sub aliyun_vswitch_spec("sieffect", Str $name) {
  qq[\$\{alicloud_vswitch.$name.id\}]
}

multi sub aliyun_vswitch_spec(|other) {
  []
}