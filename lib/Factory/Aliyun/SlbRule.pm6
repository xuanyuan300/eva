unit module Factory::Aliyun::SlbRule;

proto aliyun_slb_rule_spec(|) is export { * }

#{bind => lb-id, name => test-lb-rule, plat => aliyun, resource_type => lb_rule, values => (frontend_port => 70 server_group_id => ssssss)}
multi sub aliyun_slb_rule_spec("name", $name) {
  name => $name;
}

multi sub aliyun_slb_rule_spec("bind", Str $val) {
  load_balancer_id => $val
}

multi sub aliyun_slb_rule_spec("values", Positional:D $config) {
  my %res;
  for $config.hash.kv -> $k, $v {
    %res.push(aliyun_slb_rule_spec($k, $v).hash)
  }
  %res;
}

multi sub aliyun_slb_rule_spec("values", Associative:D $config) {
  my %res;
  for $config.kv -> $k, $v {
    %res.push(aliyun_slb_rule_spec($k, $v).hash)
  }
  %res;
}

multi sub aliyun_slb_rule_spec("frontend_port", Numeric $val) {
  frontend_port => $val;
}

multi sub aliyun_slb_rule_spec("server_group_id", Str $val) {
  server_group_id => $val;
}

multi sub aliyun_slb_rule_spec("domain", Str $val) {
  domain => $val
}

multi sub aliyun_slb_rule_spec("url", Str $val) {
  url => $val
}


multi sub aliyun_slb_rule_spec("sieffect", Str $name) {
  ;
}

multi sub aliyun_slb_rule_spec("start", Str $name) {
  qq[
resource "alicloud_slb_rule" "$name" \{\n
]
}

multi sub aliyun_slb_rule_spec("end") {
  Q[}]
}

multi sub aliyun_slb_rule_spec(|other) {
  []
}