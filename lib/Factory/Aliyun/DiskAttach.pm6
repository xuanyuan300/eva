unit module Factory::Aliyun::DiskAttach;

proto aliyun_disk_attach_spec(|) is export { * }

multi sub aliyun_disk_attach_spec(Hash $config) {
  qq[
resource "alicloud_disk_attachment" "disk_attach_$config<bind>" \{
    disk_id     = "$config<values><disk_id>"
    instance_id = "\$\{alicloud_instance.$config<bind>.id\}"
\}
]
}


multi sub aliyun_disk_attach_spec("sieffect", Str $name) {
  ;
}

multi sub aliyun_disk_spec(|other) {
  []
}