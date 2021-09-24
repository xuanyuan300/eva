unit module Factory::Openstack;
use Factory::Util::Http;

proto openstack_spec(|) is export {*};
multi sub openstack_spec("flavor", Str $flavor_name) {
  flavor_name => $flavor_name;
}

multi sub openstack_spec("name", Str $name) {
  [%(name=>$name)];
}

multi sub openstack_spec("name", Positional:D $name) {
  $name.map(-> $x {%(name=>$x)});
}

multi sub openstack_spec("name", Block $name) {
  openstack_spec("name", $name());
}

multi sub openstack_spec("image", Str $image_name) {
  :$image_name;
}

multi sub openstack_spec("sec-group", Positional:D $sec_group) {
  security_groups => $sec_group;
}

multi sub openstack_spec("sec-group", Str $sec_group) {
  security_groups => [ $sec_group ];
}

multi sub openstack_spec("network", Str $name) {
  %(network => :$name, render_args => block => True);
}

multi sub openstack_spec("network", Positional:D  $nc) {
  %(network => $nc, render_args => block => True);
}

multi sub openstack_spec("network", Hash $config) {
  %(network => $config, render_args => block => True);
}

multi sub openstack_spec("meta", Associative:D $meta ) {
  %(metadata => $meta, render_args => attr => True);
}

multi sub openstack_spec("schedule", Positional:D $config) {
  scheduler_hints => $config.Hash;
}

multi sub openstack_spec("schedule", Associative:D $config) {
  scheduler_hints => $config
}

multi sub openstack_spec("resource_type", Str $rt, Str $name) {
  given $rt {
    when "vm" {
      "openstack_compute_instance_v2", qq[resource "openstack_compute_instance_v2" "$name" \{ \n]
    }
  }
}

multi sub openstack_spec("env", "yf") {
  qq[
provider "openstack" \{
#  alias       = "test"
  user_name   = "admin"
  project_domain_name = "Default"
  user_domain_name  = "Default"
  password    = "\{get_cloud_passwd("openstack", "yf")\}"
  auth_url    = "{url}"
  tenant_name = "admin"
\}
]

}

multi sub openstack_spec("env", "sg") {
  qq[
provider "openstack" \{
#  alias       = "prod"
  user_name   = "admin"
  project_domain_name = "Default"
  user_domain_name  = "Default"
  password    = "{get_cloud_passwd("openstack", "sg")}"
  auth_url    = "{url}"
  tenant_name = "admin"
\}
]

}


multi sub openstack_spec("provider", "test") {
  provider => "openstack.test"
}

multi sub openstack_spec("provider", "prod") {
  provider => "openstack.prod"
}

multi sub openstack_spec("remote_state", $env, $bis) {
  qq[
terraform \{
  backend "etcdv3" \{
    endpoints = ["127.0.0.1:2379"]
    lock      = true
    prefix    = "/terraform-state/openstack/$env/$bis"
  \}
\}
]
}


multi sub openstack_spec("data_resource", "network", :$return, :$data_resource) {
  my $config = qq[
data "openstack_networking_network_v2" "$return" \{
    name = "$data_resource<name>"
\}
];

  %(config => $config, output => qq[\$\{data.openstack_networking_network_v2.$return.id\}]);
}

multi sub openstack_spec("interface_attach", Hash $config) {
  my $instance_id = openstack_spec("interface_attach", "bind", $config<bind>);
  my $values = $config<values>.hash;
  my $network_id = $values<network_id>;
  my $fix_ip = $values<fix_ip>;
  qq[
resource "openstack_compute_interface_attach_v2" "interface_attach_$config<bind>" \{
  instance_id = "$instance_id"
  network_id  = "$network_id"
  fixed_ip    = "$fix_ip"
\}
]
}

multi sub openstack_spec("interface_attach", "bind",  Positional:D $name) {
  #return array
  []
}

multi sub openstack_spec("interface_attach", "bind", Str $name) {
  qq[\$\{openstack_compute_instance_v2.$name.id\}]
}

multi sub openstack_spec(|other) {
  [];
}
