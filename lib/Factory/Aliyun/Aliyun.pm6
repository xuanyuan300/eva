unit module Factory::Aliyun::VM;
use Factory::Util::Http;

proto aliyun_spec(|) is export { * }

multi sub aliyun_spec("flavor", Str $flavor_name) {
    instance_type => $flavor_name;
}

sub get_name(Str $name="") {
    state $x;
    if ( $name ne "") { $x = $name };
    $x;
}

multi sub aliyun_spec("name", Str $name, $_) {
    get_name($name);
}

multi sub aliyun_spec("name", Str $name) {
    [%(instance_name=>$name)];
}

multi sub aliyun_spec("name", Positional:D $name) {
  $name.map(-> $x {%(instance_name=>$x)});
}

multi sub aliyun_spec("name", Block $name) {
  aliyun_spec("name", $name());
}

multi sub aliyun_spec("image", Str $image_name) {
    image_id => $image_name;
}

multi sub aliyun_spec("sec_group", Positional:D $sec_group) {
    security_groups => $sec_group;
}

multi sub aliyun_spec("sec_group", Str $sec_group) {
    security_groups => [ $sec_group ];
}

multi sub aliyun_spec("vswitch_id", Str $vid) {
    vswitch_id => $vid;
}

sub get_vswitch_id(Str $az="") {
    state $x;
    if ( $az ne "" ) { $x = $az };
    $x;
}

multi sub aliyun_spec("vswitch_id", Associative:D $val) {
    vswitch_id => $val{get_vswitch_id};
}

multi sub aliyun_spec("system_disk_category", Str $sdc) {
    system_disk_category => $sdc;
}

multi sub aliyun_spec("instance_charge_type", Str $val) {
  instance_charge_type => $val;
}

multi sub aliyun_spec("internet_charge_type", Str $val) {
  internet_charge_type => $val;
}

multi sub aliyun_spec("internet_max_bandwidth_out", Str $imbo) {
    internet_max_bandwidth_out => $imbo;
}

multi sub aliyun_spec("system_disk_size", Str $sds) {
    system_disk_size => $sds;
}

multi sub aliyun_spec("host_name", Str $hn) {
    host_name => $hn;
}

multi sub aliyun_spec("host_name", "same_name") {
    host_name => get_name;
}

multi sub aliyun_spec("tags", Associative:D $val) {
  my %tags = $val.kv.map(-> $k,$v { $k =>  $v eq "same_name" ?? get_name.split(".")[0] !! $v }).hash;
  :%tags;
}

multi sub aliyun_spec("private_ip", Str $pip) {
    private_ip => $pip;
}

multi sub aliyun_spec("force_delete", Bool $fd) {
    force_delete => $fd;
}

multi sub aliyun_spec("deletion_protection", Bool $dp) {
    deletion_protection => $dp;
}

multi sub aliyun_spec("delete_with_instance", Bool $dwi) {
    delete_with_instance => $dwi;
}

multi sub aliyun_spec("data_disks", Positional:D $dd) {
    data_disks => $dd;
}

multi sub aliyun_spec("data_disks", Hash $dd) {
    data_disks => $dd;
}

multi sub aliyun_spec("snapshot_id", Str $sid) {
    snapshot_id => $sid;
}

multi sub aliyun_spec("role_name", Str $rn) {
    role_name => $rn;
}

multi sub aliyun_spec("period_unit", Str $val) {
  period_unit => $val;
}

multi sub aliyun_spec("period", Int $val) {
  period => $val;
}

multi sub aliyun_spec("renewal_status", Str $val) {
  renewal_status => $val;
}

multi sub aliyun_spec("auto_renew_period", Int $val) {
  auto_renew_period => $val;
}

multi sub aliyun_spec("az", Str $az, $_) {
    availability_zone => $az
}

multi sub aliyun_spec("az", Positional:D $az, $idx) {
  my $sel_az = ($idx + 1) % 2 == 1 ?? $az[0] !! $az[1];
  get_vswitch_id($sel_az);
  availability_zone => $sel_az;
}

multi sub aliyun_spec("region", Str $r) {
    qq[
provider "alicloud" \{
  access_key = "{get_cloud_passwd("aliyun")<access_key>}"
  secret_key = "{get_cloud_passwd("aliyun")<secret_key>}"
  region     = "$r"
\}
]
}

multi sub aliyun_spec("region", Positional:D $r) {

}

multi sub aliyun_spec("resource_type", Str $rt, Str $name) {
    given $rt {
        when "vm" {
            "alicloud_instance", qq[
resource "alicloud_instance" "$name" \{ \n
]
        }
    }
}

multi sub aliyun_spec("env", $arg) {
 qq[
provider "alicloud" \{
  access_key = "{get_cloud_passwd("aliyun")<access_key>}"
  secret_key = "{get_cloud_passwd("aliyun")<secret_key>}"
  region     = "$arg"
\}
]
}

multi sub aliyun_spec("data_resource", "sec_group", :$return, :$data_resource) {
    my $config = qq[
data "alicloud_security_groups" "$return" \{
    name_regex = "^$data_resource<name>"
\}
];

    %(config => $config, output => qq[\$\{data.alicloud_security_group.$return.*.id\}]);
}

multi sub aliyun_spec("data_resource", "lb_server_cert", :$return, :$data_resource) {
  my $config = qq[
data "alicloud_slb_server_certificates" "$return" \{
    name_regex = "$data_resource<name_regex>"
\}
];

  %(config => $config, output => qq[\$\{data.alicloud_slb_server_certificates.$return.0.id\}]);
}

multi sub aliyun_spec("data_resource", "lb", :$return, :$data_resource) {
  my $config = qq[
data "alicloud_slbs" "$return" \{
  name_regex = "$data_resource<name_regex>"
\}
];
  %(config => $config, output => qq[\$\{data.alicloud_slbs.$return.0.id\}]);
}

multi sub aliyun_spec("data_resource", "vpc", :$return, :$data_resource) {
  my $config = qq[
data "alicloud_vpcs" "$return" \{
  name_regex = "$data_resource<name_regex>"
\}
];

  %(config => $config, output => qq[\$\{data.alicloud_vpcs.$return.0.id\}]);
}

multi sub aliyun_spec("data_resource", "vswitch", :$return, :$data_resource) {
  my $config = qq[
data "alicloud_vswitches" "$return" \{
    name_regex = "$data_resource<name_regex>"
\}
];
  %(config => $config, output => qq[\$\{data.alicloud_vswitches.$return.0.id\}])
}

multi sub aliyun_spec(|other) {
    [];
}

=begin pod
=head3 创建阿里云虚机的相关参数列表

以下参数使用方式为:
在DSL语句的B<values>后面添加, 一个参数为一个C<Pair>, 多个参数用逗号隔开, 具体为:

  ... values key1 => value1, key2 => vlaue2 ...

=head3 与terraform原生参数差异点:

除以下参数为,其余参数均与terraform的参数相同, L<详细使用说明|https://www.terraform.io/docs/providers/alicloud/r/instance.html>

=begin item
I<name>

  对应terraform的B<instance_name>, 指定名称, 参数类型为Str, Array, Block
=end item

=begin item
I<image>

  对应terraform的B<image_id>, 指定镜像名称, 参数类型为Str
=end item

=begin item
I<sec_group>

  对应terraform的B<security_groups>, 指定安全组, 参数类型为Str, Array
=end item

=begin item
I<az>

  对应terraform的B<availability_zone>, 指定可用区, 参数类型为Str
=end item

=end pod
