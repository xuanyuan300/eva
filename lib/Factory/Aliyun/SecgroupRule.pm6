unit module Factory::Aliyun::SecgroupRule;

proto aliyun_sgr_spec(|) is export { * }
# {resource_type => secgroup_rule, rules => ({accept => (aa => 123)} {deny => (aa => 123)})}
multi sub aliyun_sgr_spec("rules", Positional:D $rls) {
  my @res;
  for $rls -> $rl {
    for $rl.kv -> $k, $v {
      @res.push(aliyun_sgr_spec($k, $v.flat.hash))
    }
  }
  @res
}

multi sub aliyun_sgr_spec("parse", Hash $config) {
  my %res;
  for $config.kv -> $k, $v {
    my $tmp = aliyun_sgr_spec($k, $v);
    %res.push($tmp.hash) if $tmp;
  }
  %res
}

multi sub aliyun_sgr_spec("accept", Hash $config) {
  aliyun_sgr_spec("parse", $config)
}

multi sub aliyun_sgr_spec("deny", Hash $config) {
  aliyun_sgr_spec("parse", $config)
}

multi sub aliyun_sgr_spec("value", $val where { $val.^name eq "List"}) {
  my %res;
  for $val.hash.kv -> $k, $v {
    my $tmp = aliyun_sgr_spec($k, $v);
    %res.push(%($tmp.key => $tmp.value)) if $tmp
  }
  %res
}

#type              = "ingress"
#  ip_protocol       = "tcp"
#  nic_type          = "internet"
#  policy            = "accept"
#  port_range        = "1/65535"
#  priority          = 1
#  security_group_id = "${alicloud_security_group.default.id}"
#  cidr_ip           = "0.0.0.0/0"
multi sub aliyun_sgr_spec("type", Str $rt) {
  type => $rt
}

multi sub aliyun_sgr_spec("protocol", Str $pro) {
  ip_protocol => $pro
}

multi sub aliyun_sgr_spec("nic_type", Str $nt) {
  nic_type => $nt
}

multi sub aliyun_sgr_spec("priority", Int $pri) {
  priority => $pri
}

multi sub aliyun_sgr_spec("sgid", Str $id) {
  security_group_id => $id
}

multi sub aliyun_sgr_spec("cidr", Str $cip) {
  cidr_ip => $cip
}

multi sub aliyun_sgr_spec("port_range", Positional:D $range) {
  if $range.elems == 1 {
      port_range => "$range/$range"
  }else{
      port_range => "$range[0]/$range[1]"
  }
}

multi sub aliyun_sgr_spec("name", Str $name ) {
  name => $name;
}

multi sub aliyun_sgr_spec("accept") {
  policy => "accept"
}

multi sub aliyun_sgr_spec("start",  Str $name) {
  qq[
resource "alicloud_security_group_rule" "$name" \{\n
]
}

multi sub aliyun_sgr_spec("end") {
  Q[}]
}
multi sub aliyun_sgr_spec(|other) {
  ;
}
