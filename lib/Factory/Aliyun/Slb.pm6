unit module Factory::Aliyun::Slb;

proto aliyun_slb_spec(|) is export { * }

multi sub aliyun_slb_spec("name", Str $name) {
  name => $name
}

multi sub aliyun_slb_spec("values", Positional:D $config) {
  my %res;
  for $config.hash.kv -> $k, $v {
    %res.push(aliyun_slb_spec($k, $v).hash)
  }
  %res;
}

multi sub aliyun_slb_spec("internet", Bool $internet) {
  internet => $internet
}

multi sub aliyun_slb_spec("internet_charge_type", Str $val) {
  internet_charge_type => $val;
}

multi sub aliyun_slb_spec("bandwidth", Str $val) {
  bandwidth => $val
}

multi sub aliyun_slb_spec("vswitch_id", Str $val) {
  vswitch_id => $val
}

multi sub aliyun_slb_spec("spec", Str $val) {
  specification => $val
}

multi sub aliyun_slb_spec("tags", Hash $tags) {
  tags => $tags
}

multi sub aliyun_slb_spec("instance_charge_type", Str $instance_charge_type) {
  instance_charge_type => $instance_charge_type
}

multi sub aliyun_slb_spec("period", Str $val) {
  period => $val
}

multi sub aliyun_slb_spec("master_zone_id", Str $val) {
  master_zone_id => $val
}

multi sub aliyun_slb_spec("slave_zone_id", Str $val) {
  slave_zone_id => $val
}

multi sub aliyun_slb_spec("sieffect", Str $name) {
  qq[\$\{alicloud_slb.$name.id\}];
}

multi sub aliyun_slb_spec("start", Str $name) {
  qq[
resource "alicloud_slb" "$name" \{\n
]
}

multi sub aliyun_slb_spec("end") {
  Q[}]
}
multi sub aliyun_slb_spec(|other) {
  []
}