unit module Factory::Aliyun::Disk;

proto aliyun_disk_spec(|) is export { * }

#{name => test-disk, plat => aliyun, resource_type => disk, values => size => 50}
multi sub aliyun_disk_spec("name", Str $name) {
  name => $name
}

multi sub aliyun_disk_spec("az", Str $name) {
  availability_zone => $name
}

multi sub aliyun_disk_spec("values", Positional:D $values) {
  my %res;
  for $values.hash.kv -> $k, $v {
    %res.push(aliyun_disk_spec($k, $v).hash)
  }

  %res;
}

multi sub aliyun_disk_spec("values", Associative:D $values) {
  $values
}

multi sub aliyun_disk_spec("size", $size) {
  size => $size
}

#`[
availability_zone = "cn-beijing-b"
  name              = "New-disk"
  description       = "Hello ecs disk."
  category          = "cloud_efficiency"
  size
]

multi sub aliyun_disk_spec("desc", Str $desc) {
  desc => $desc
}

multi sub aliyun_disk_spec("category", Str $category) {
  category => $category
}

multi sub aliyun_disk_spec("tags", Hash $tags) {
  tags => $tags
}

multi sub aliyun_disk_spec("where", Associative:D $where ) {
  availability_zone => $where<az>
}

multi sub aliyun_disk_spec("start", Str $name) {
  qq[
resource "alicloud_disk" "$name" \{\n
]
}

multi sub aliyun_disk_spec("end") {
  Q[}]
}

multi sub aliyun_disk_spec("sieffect", Str $name) {
  qq[\$\{alicloud_disk.$name.id\}]
}

multi sub aliyun_disk_spec(|other) {
  []
}