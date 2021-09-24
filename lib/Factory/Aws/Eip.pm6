unit module Factory::Aws::Eip;
use Factory::Util::Http;

proto aws_eip_spec(|) is export { * }

multi sub aws_eip_spec("values", Positional:D $val) {
  aws_eip_spec("values", $val.hash);
}

multi sub aws_eip_spec("values", Associative:D $val) {
  my %res;
  for $val.kv -> $k, $v {
    %res.push(aws_eip_spec($k, $v).hash);
  }

  %res;
}

multi sub aws_eip_spec("vpc", Bool $val) {
    vpc => $val;
}


multi sub aws_eip_spec("instance", Str $name) {
    instance => $name;
}

multi sub aws_eip_spec("start", Str $name) {
    qq[
resource "aws_eip" "$name" \{ \n
]
}

multi sub aws_eip_spec("end") {
  Q[}]
}

multi sub aws_eip_spec(|other) {
    [];
}

