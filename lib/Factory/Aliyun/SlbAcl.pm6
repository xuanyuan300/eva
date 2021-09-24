unit module Factory::Aliyun::SlbAcl;

proto aliyun_slb_acl_spec(|) is export { * }

#{name => test-lb-acl, plat => aliyun, resource_type => lb_acl, values => (ip_version => ipv4 entry_list => {entry => 10.10.10.0/24})}
multi sub aliyun_slb_acl_spec("name", $name) {
  name => $name;
}

multi sub aliyun_slb_acl_spec("ip_version", Str $val) {
  ip_version => $val
}

multi sub aliyun_slb_acl_spec("values", Positional:D $config) {
  my %res;
  for $config.hash.kv -> $k, $v {
    %res.push(aliyun_slb_acl_spec($k, $v).hash)
  }
  %res;
}

multi sub aliyun_slb_acl_spec("values", Associative:D $config) {
  my %res;
  for $config.kv -> $k, $v {
    %res.push(aliyun_slb_acl_spec($k, $v).hash)
  }
  %res;
}

multi sub aliyun_slb_acl_spec("entry_list", Positional:D $val) {
  entry_list => $val;
}

multi sub aliyun_slb_acl_spec("entry_list", Associative:D $val) {
  entry_list => [ $val ];
}


multi sub aliyun_slb_acl_spec("sieffect", Str $name) {
  ;
}

multi sub aliyun_slb_acl_spec("start", Str $name) {
  qq[
resource "alicloud_slb_acl" "$name" \{\n
]
}

multi sub aliyun_slb_acl_spec("end") {
  Q[}]
}

multi sub aliyun_slb_acl_spec(|other) {
  []
}