use Factory::Call;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::HTTP::Log::File;


sub listen(Str $host, Int $port) is export {
  my %tls = private-key-file => 'localhost.key',
            certificate-file => 'localhost.crt';
 
  my $application = route {
    post -> 'config' {
      request-body 'application/json' => -> (:$config!) {
        content 'application/json', parse_config($config);
      }
    }
  }
  
  my Cro::Service $service = Cro::HTTP::Server.new(
    :$host, :$port, :%tls, :$application,
    after => [
        Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
  );
 
  $service.start;
  react whenever signal(SIGINT) {
    $service.stop;
    exit;
  }
}

