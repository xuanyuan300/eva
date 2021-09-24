unit module Factory::Aliyun::SlbServergroup;

proto aliyun_slb_servergroup_spec(|) is export { * }

#{bind => ${alicloud_slb.test-lb.id}, name => test-lb-sg, plat => aliyun, values => servers => {server_ids => (1 2), weight => 100}}
multi sub aliyun_slb_servergroup_spec("name", Str $name) {
  name => $name
}

multi sub aliyun_slb_servergroup_spec("bind", Str $val) {
  load_balancer_id => $val
}

multi sub aliyun_slb_servergroup_spec("values", Positional:D $config) {
  my %res;
  for $config.hash.kv -> $k, $v {
    %res.push(aliyun_slb_servergroup_spec($k, $v).hash)
  }
  %res;
}

multi sub aliyun_slb_servergroup_spec("values", Associative:D $config) {
  my %res;
  for $config.kv -> $k, $v {
    %res.push(aliyun_slb_servergroup_spec($k, $v).hash)
  }
  %res;
}

multi sub aliyun_slb_servergroup_spec("servers", Positional:D $config) {
  my @res;
  for $config -> $v {
    @res.push(aliyun_slb_servergroup_spec("server", $v).hash)
  }
  %(servers => @res);
}

multi sub aliyun_slb_servergroup_spec("servers", Associative:D $config) {
  my @res;
  for $config.kv -> $k, $v {
    @res.push(aliyun_slb_servergroup_spec($k, $v).hash)
  }
  %(servers => @res);
}

multi sub aliyun_slb_servergroup_spec("server", Associative:D $config) {
  my %res;
  for $config.kv -> $k, $v {
    %res.push(aliyun_slb_servergroup_spec($k, $v).hash)
  }
  %res;
}

multi sub aliyun_slb_servergroup_spec("server_ids", Str $val) {
  server_ids => [ $val ];
}

multi sub aliyun_slb_servergroup_spec("server_ids", Positional:D $val) {
  server_ids => $val;
}

multi sub aliyun_slb_servergroup_spec("port", Numeric $val) {
  port => $val
}

multi sub aliyun_slb_servergroup_spec("weight", Numeric $val) {
  weight => $val
}

multi sub aliyun_slb_servergroup_spec("sieffect", Str $name) {
  qq[\$\{alicloud_slb_server_group.$name.id\}];
}

multi sub aliyun_slb_servergroup_spec("start", Str $name) {
  qq[
resource "alicloud_slb_server_group" "$name" \{\n
]
}

multi sub aliyun_slb_servergroup_spec("end") {
  Q[}]
}
multi sub aliyun_slb_servergroup_spec(|other) {
  []
}