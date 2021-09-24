unit module Factory::Aliyun::Secgroup;

proto aliyun_sg_spec(|) is export { * }
# {resource_type => secgroup_rule, rules => ({accept => (aa => 123)} {deny => (aa => 123)})}
multi sub aliyun_sg_spec("secgroup", Hash $config) {
  my %config;
  for $config.kv -> $k, $v {
    my $tmp = aliyun_sg_spec($k, $v);
    %config.push($tmp.hash)
  }

  %(config => %config, output => qq[\$\{alicloud_security_group.%config<name>.id\}]);
}

#{name => sg, plat => aliyun, values => aa => 4444}

multi sub aliyun_sg_spec("values", Pair $values) {
  my %res;
  for $values.kv -> $k, $v {
    my $tmp = aliyun_sg_spec($k, $v);
    %res.push($tmp) if $tmp;
  }
  %res;
}

multi sub aliyun_sg_spec("values", List $values) {
  my %res;
  for $values.hash.kv -> $k, $v {
    my $tmp = aliyun_sg_spec($k, $v);
    %res.push($tmp) if $tmp;
  }
  %res
}

multi sub aliyun_sg_spec("name", Str $name) {
  name => $name
}

multi sub aliyun_sg_spec("vpc_id", Str $id) {
  vpc_id => $id
}

multi sub aliyun_sg_spec("description", Str $desc) {
  description => $desc
}

multi sub aliyun_sg_spec("inner_access", Bool $ia) {
  inner_access => $ia
}

multi sub aliyun_sg_spec("tags", Hash $tags) {
  tags => $tags
}

multi sub aliyun_sg_spec("start", Str $name) {
  qq[
resource "alicloud_security_group" "$name" \{\n
]
}

multi sub aliyun_sg_spec("end") {
  Q[}]
}

multi sub aliyun_sg_spec(|other) {
  ;
}