unit module Factory::Aws::VM;
use Factory::Util::Http;

proto aws_spec(|) is export { * }

multi sub aws_spec("flavor", Str $flavor_name) {
    instance_type => $flavor_name;
}

sub get_name(Str $name="") {
    state $x;
    if ( $name ne "") { $x = $name };
    $x;
}

multi sub aws_spec("name", Str $name, $_) {
    [ name => get_name($name) ];
}

multi sub aws_spec("name", Str $name) {
    [ name => get_name($name) ];
}

multi sub aws_spec("name", Positional:D $name) {
  $name.map(-> $x {%(name=>$x)});
}

multi sub aws_spec("name", Block $name) {
    aws_spec("name", $name());
}

multi sub aws_spec("image", Str $image_name) {
    ami => $image_name;
}

multi sub aws_spec("disable_api_termination", Bool $val) {
    disable_api_termination => $val;
}

multi sub aws_spec("sec_group", Positional:D $sec_group) {
    security_groups => $sec_group;
}

multi sub aws_spec("sec_group", Str $sec_group) {
    security_groups => [ $sec_group ];
}

multi sub aws_spec("vpc_sec_group", Positional:D $val) {
    vpc_security_group_ids => $val;
}

multi sub aws_spec("vpc_sec_group", Str $val ) {
    vpc_security_group_ids => [ $val ];
}

multi sub aws_spec("subnet_id", Str $val) {
    subnet_id => $val;
}

sub get_subnet_id(Str $az="") {
    state $x;
    if ( $az ne "" ) { $x = $az };
    $x;
}

multi sub aws_spec("subnet_id", Associative:D $val) {
    subnet_id => $val{get_subnet_id};
}

multi sub aws_spec("root_block_device", Associative:D $val) {
    root_block_device => $val;
}

multi sub aws_spec("tags", Associative:D $val) {
    tags => $val.kv.map(-> $k,$v { $k =>  $v eq "same_name" ?? get_name.split(".")[0] !! $v }).hash;
}

multi sub aws_spec("private_ip", Str $pip) {
    private_ip => $pip;
}

multi sub aws_spec("volume_tags", Associative:D $val) {
    volume_tags => $val.kv.map(-> $k,$v { $k =>  $v eq "same_name" ?? get_name.split(".")[0] !! $v }).hash;
}

multi sub aws_spec("ebs_block_device", Associative:D $val) {
    ebs_block_device => $val;
}

multi sub aws_spec("role_name", Str $rn) {
    iam_instance_profile => $rn;
}

multi sub aws_spec("az", Str $az) {
    availability_zone => $az;
}

multi sub aws_spec("az", Str $az, $_) {
    availability_zone => $az
}

multi sub aws_spec("az", Positional:D $az, $idx) {
  my $sel_az = ($idx + 1) % 2 == 1 ?? $az[0] !! $az[1];
  get_subnet_id($sel_az);
  availability_zone => $sel_az;
}

multi sub aws_spec("region", Str $r) {
    qq[
provider "aws" \{
  access_key = "get_cloud_passwd("aws")<access_key>"
  secret_key = "get_cloud_passwd("aws")<secret_key>"
  region     = "$r"
\}
]
}

multi sub aws_spec("region", Positional:D $r) {

}

multi sub aws_spec("resource_type", Str $rt, Str $name) {
    given $rt {
        when "vm" {
            "aws_instance", qq[
resource "aws_instance" "$name" \{ \n
]
        }
    }
}

multi sub aws_spec("env", $arg) {
 qq[
provider "aws" \{
  access_key = "get_cloud_passwd("aliyun")<access_key>"
  secret_key = "get_cloud_passwd("aliyun")<secret_key>"
  region     = "$arg"
\}
]
}

multi sub aws_spec("data_resource", "sec_group", :$return, :$data_resource) {
    my $config = qq[
data "aws_security_group" "$return" \{
    name = "$data_resource<name>"
\}
];

    %(:$config, output => qq[\$\{data.aws_security_group.$return.*.id\}]);
}


multi sub aws_spec("data_resource", "alb", :$return, :$data_resource) {
  my Str $args;
  if $data_resource<name> {
    $args ~= "  name = \"$data_resource<name>\"\n"
  }

  if $data_resource<arn> {
    $args ~= "  arn = \"$data_resource<arn>\"\n"
  }

  my $config = qq[
data "aws_alb" "$return" \{
  $args
\}
];
  %(:$config, output => qq[\$\{data.aws_alb.$return.0.id\}]);
}

multi sub aws_spec("data_resource", "vpc", :$return, :$data_resource) {
  my $config = qq[
data "aws_vpc" "$return" \{
  vpc_id = "$data_resource<id>"
\}
];

  %(:$config, output => qq[\$\{data.aws_alb.$return.0.id\}]);
}

multi sub aws_spec("data_resource", "subnet", :$return, :$data_resource) {
  my $config = qq[
data "aws_subnet" "$return" \{
    id = "$data_resource<id>"
\}
];
  %(:$config, output => qq[\$\{data.aws_subnet.$return.0.id\}])
}

multi sub aws_spec(|other) {
    [];
}

