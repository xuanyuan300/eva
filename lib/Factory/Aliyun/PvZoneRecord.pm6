unit module Factory::Aliyun::PvZoneRecord;

proto aliyun_pvzone_record_spec(|) is export { * }

#{bind => saaaa, name => sssa, plat => aliyun, resource_type => pvzone_record, values => (type => A value => sss)}
multi sub aliyun_pvzone_record_spec("name", Str $name) {
    [];
}

multi sub aliyun_pvzone_record_spec("values", Positional:D $val) {
    aliyun_pvzone_record_spec("values", $val.hash);
}

multi sub aliyun_pvzone_record_spec("values", Associative:D $val) {
    my %res;
    for $val.kv -> $k, $v {
        %res.push(aliyun_pvzone_record_spec($k, $v).hash);
    }
    %res;
}

multi sub aliyun_pvzone_record_spec("bind", Str $val) {
    zone_id => $val;
}

multi sub aliyun_pvzone_record_spec("resource_record", Str $val) {
    resource_record => $val;
}

multi sub aliyun_pvzone_record_spec("type", Str $val) {
    type => $val.uc;
}

multi sub aliyun_pvzone_record_spec("value", Str $val) {
    value => $val;
}

multi sub aliyun_pvzone_record_spec("ttl", Str $val) {
    ttl => $val;
}

multi sub aliyun_pvzone_record_spec("depends_on", Str $val) {
    depends_on => [ "alicloud_instance.$val" ]
}

multi sub aliyun_pvzone_record_spec("start", Str $name) {
    qq[
resource "alicloud_pvtz_zone_record" "$name" \{\n
]
}

multi sub aliyun_pvzone_record_spec("end") {
    Q[}]
}

multi sub aliyun_pvzone_record_spec("sieffect", Str $name) {
    qq[\$\{alicloud_vswitch.$name.id\}]
}

multi sub aliyun_pvzone_record_spec(|other) {
    []
}