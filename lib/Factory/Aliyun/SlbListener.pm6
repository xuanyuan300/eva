unit module Factory::Aliyun::SlbListener;

proto aliyun_slb_listener_spec(|) is export { * }

multi sub aliyun_slb_listener_spec("bind", Str $val) {
  load_balancer_id => $val;
}

multi sub aliyun_slb_listener_spec("values", Positional:D $val) {
  my %res;
  for $val.hash.kv -> $k, $v {
    %res.push(aliyun_slb_listener_spec($k, $v).hash)
  }
  %res
}

multi sub aliyun_slb_listener_spec("frontend_port", Numeric $val) {
  frontend_port => $val;
}

multi sub aliyun_slb_listener_spec("backend_port", Numeric $val) {
  backend_port => $val;
}

multi sub aliyun_slb_listener_spec("protocol", Str $val) {
  protocol  => $val;
}

multi sub aliyun_slb_listener_spec("bandwidth", Str $val) {
  bandwidth => $val
}

multi sub aliyun_slb_listener_spec("scheduler", Str $val) {
  scheduler => $val
}

multi sub aliyun_slb_listener_spec("sticky_session", Str $val) {
  sticky_session => $val
}

multi sub aliyun_slb_listener_spec("sticky_session_type ", Str $val) {
  sticky_session_type => $val;
}

multi sub aliyun_slb_listener_spec("cookie_timeout", Str $val) {
  cookie_timeout => $val;
}

multi sub aliyun_slb_listener_spec("cookie", Str $val) {
  cookie => $val
}

multi sub aliyun_slb_listener_spec("persistence_timeout", Str $val) {
  persistence_timeout => $val
}

multi sub aliyun_slb_listener_spec("health_check", Str $val) {
  health_check => $val
}

multi sub aliyun_slb_listener_spec("health_check_type", Str $val) {
  health_check_type => $val
}

multi sub aliyun_slb_listener_spec("health_check_domain", Str $val) {
  health_check_domain => $val
}

multi sub aliyun_slb_listener_spec("health_check_uri", Str $val) {
  health_check_uri => $val
}

multi sub aliyun_slb_listener_spec("health_check_connect_port", Numeric $val) {
  health_check_connect_port => $val
}

multi sub aliyun_slb_listener_spec("healthy_threshold", Numeric $val) {
  healthy_threshold => $val
}

multi sub aliyun_slb_listener_spec("unhealthy_threshold", Numeric $val) {
  unhealthy_threshold => $val
}

multi sub aliyun_slb_listener_spec("health_check_timeout", Numeric $val) {
  health_check_timeout => $val
}

multi sub aliyun_slb_listener_spec("health_check_interval", Numeric $val) {
  health_check_interval => $val
}

multi sub aliyun_slb_listener_spec("health_check_http_code", Str $val) {
  health_check_http_code => $val
}

multi sub aliyun_slb_listener_spec("ssl_certificate_id", Str $val) {
  ssl_certificate_id => $val
}

multi sub aliyun_slb_listener_spec("gzip", Bool $val) {
  gzip => $val
}

multi sub aliyun_slb_listener_spec("health_check_http_code", Str $val) {
  health_check_http_code => $val
}

multi sub aliyun_slb_listener_spec("x_forwarded_for", Hash $val) {
  x_forwarded_for => $val
}

multi sub aliyun_slb_listener_spec("acl_status", Str $val) {
  acl_status => $val
}

multi sub aliyun_slb_listener_spec("acl_type", Str $val) {
  acl_type => $val
}

multi sub aliyun_slb_listener_spec("acl_id", Str $val) {
  acl_id => $val
}

multi sub aliyun_slb_listener_spec("established_timeout", Numeric $val) {
  established_timeout  => $val
}

multi sub aliyun_slb_listener_spec("idle_timeout", Numeric $val) {
  idle_timeout  => $val
}

multi sub aliyun_slb_listener_spec("request_timeout", Numeric $val) {
  request_timeout  => $val
}

multi sub aliyun_slb_listener_spec("enable_http2", Str $val) {
  enable_http2 => $val
}

multi sub aliyun_slb_listener_spec("tls_cipher_policy", Str $val) {
  tls_cipher_policy => $val
}

multi sub aliyun_slb_listener_spec("server_group_id", Str $val) {
  server_group_id  => $val
}

multi sub aliyun_slb_listener_spec("listener_forward", Str $val) {
  listener_forward => $val
}

multi sub aliyun_slb_listener_spec("forward_port", Str $val) {
  forward_port => $val
}

multi sub aliyun_slb_listener_spec("sieffect", Str $name) {
  qq[\$\{alicloud_slb.$name.id\}];
}

multi sub aliyun_slb_listener_spec("start", Str $name) {
  qq[
resource "alicloud_slb_listener" "$name" \{\n
]
}

multi sub aliyun_slb_listener_spec("end") {
  Q[}]
}

multi sub aliyun_slb_listener_spec("sieffect", Str $name) {
  ;
}


multi sub aliyun_slb_listener_spec(|other) {
  []
}