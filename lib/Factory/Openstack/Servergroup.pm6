unit module Factory::Openstack::Servergroup;

proto openstack_servergroup_spec(|) is export {*};
multi sub openstack_servergroup_spec("region", Str $region) {
  region => $region;
}

multi sub openstack_servergroup_spec("name", Str $name) {
  name => $name;
}

multi sub openstack_servergroup_spec("values", Positional:D $val) {
  my %res;
  for $val.hash.kv -> $k, $v {
    %res.push(openstack_servergroup_spec($k, $v).hash)
  }

  %res;
}

multi sub openstack_servergroup_spec("values", Associative:D $val) {
  my %res;
  for $val.kv -> $k, $v {
    %res.push(openstack_servergroup_spec($k, $v).hash)
  }

  %res;
}

multi sub openstack_servergroup_spec("policies", Positional:D $policies) {
  policies => $policies ;
}

multi sub openstack_servergroup_spec("policies", Str:D $policies) {
  policies => [ $policies ];
}

multi sub openstack_servergroup_spec("start", Str $name) {
  qq[
resource "openstack_compute_servergroup_v2" "servergroup_$name" \{\n
]
}

multi sub openstack_servergroup_spec("end") {
  Q[}]
}

multi sub openstack_servergroup_spec("sieffect", Str $name) {
  qq[\$\{openstack_compute_servergroup_v2.servergroup_$name.id\}]
}

multi sub openstack_servergroup_spec(|other) {
  []
}