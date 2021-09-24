unit module Factory::Util::Http;
use Cro::HTTP::Client;

proto get_cloud_passwd(|) is export { * }

multi sub get_cloud_passwd(Str $cloud_name, Str $env) {
  my $url = "${url}";
  my $token = "${token}";
  request($url, $token)<data><passwd>
}

multi sub get_cloud_passwd("aliyun") {
  my $url = "${url}";
  my $token = "{$token};
  request($url, $token)<data>;
}

sub request(Str $url, Str $token) {
  my $resp = await Cro::HTTP::Client.get: $url,
          headers => [
            Cro::HTTP::Header.new(
                    name => "X-Vault-Token",
                    value => $token
                    )
          ];

  my $body  = await $resp.body;
  $body;
}

