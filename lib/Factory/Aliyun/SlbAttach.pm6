unit module Factory::Aliyun::SlbAttach;

proto aliyun_slb_attach_spec(|) is export { * }

#{bind => lb-id, name => test, plat => aliyun, resource_type => lb_attach, values => instance_ids => (1 2)}
multi sub aliyun_slb_attach_spec("name", Str $name) {
  [];
}

multi sub aliyun_slb_attach_spec("bind", Str $val) {
  load_balancer_id => $val
}

multi sub aliyun_slb_attach_spec("values", Positional:D $config) {
  my %res;
  for $config.hash.kv -> $k, $v {
    %res.push(aliyun_slb_attach_spec($k, $v).hash)
  }
  %res;
}

multi sub aliyun_slb_attach_spec("values", Associative:D $config) {
  my %res;
  for $config.kv -> $k, $v {
    %res.push(aliyun_slb_attach_spec($k, $v).hash)
  }
  %res;
}

multi sub aliyun_slb_attach_spec("instance_ids", Positional:D $config) {
  instance_ids => $config
}

multi sub aliyun_slb_attach_spec("instance_ids", Str $val) {
  instance_ids => [ $val ];
}

multi sub aliyun_slb_attach_spec("weight", Numeric $val) {
  weight => $val
}

multi sub aliyun_slb_attach_spec("sieffect", Str $name) {
  ;
}

multi sub aliyun_slb_attach_spec("start", Str $name) {
  qq[
resource "alicloud_slb_attachment" "$name" \{\n
]
}

multi sub aliyun_slb_attach_spec("end") {
  Q[}]
}
multi sub aliyun_slb_attach_spec(|other) {
  []
}