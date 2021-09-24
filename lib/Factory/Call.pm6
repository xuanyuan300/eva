unit module Factory::Call;

use Factory::Factory;
use Factory::Grammar::Actions;
use Factory::Grammar::Grammar;
use nqp;

sub gen_resource_vm($rt, $plat, $item) {
  my %have = $item<have>.Hash;
  my $names = $plat("name", %have<name>);
  my $only_ident = (%have<only_ident>:exists and %have<only_ident> == True) ?? True !! False;
  $item<resource_type>:delete;
  my @res;
  for $names.Array.sort.kv -> $idx, $v {
    my $content = "";
    my $depth = 0;

    my ($real_rt, $start) = $plat("resource_type", $rt, ($v<name> || $v<instance_name>).split(".")[0]);

    if $item<keep> {
      get_keep(%(resource => $real_rt, name=> ($v<name> || $v<instance_name>).split(".")[0], keep => $item<keep>));
    }

    if $item<where> and $item<where>.hash<az> {
      gen($plat("az", $item<where>.hash<az>, $idx), $content, $depth);
    }

    #gen($plat("provider", $item<in>), $content, $depth) if $item<in>;

    $plat("name", $v<name> || $v<instance_name>, $idx);
    gen($v, $content, $depth) unless $only_ident;

    for $item<values>.Hash.kv -> $k,$v {
      my $sv = $plat($k, $v);
      if $sv{"render_args"} {
          my $render_args = $sv{"render_args"};
          $sv{"render_args"}:delete;
          gen($sv, $content, $depth, $render_args);
      }else{
          gen($sv, $content, $depth);
      }
    }
    @res.push($start ~ $content ~ '}' ~ "\n");
  }
  @res.join("\n");
}

sub get_resource_vm_item(Associative:D $item) {
    my $rt = $item<resource_type>;
    my $plat = get_plat($item<plat>, $rt);
    my @items;
    my $res = gen_resource_vm($rt, $plat, $item);
    @items.push($res);

    # my $provider = get_provider_config($plat, $item);
    my $parts_count = $item<parts> ?? $item<parts>.map(*<have>.Hash<count>).sum !! 0;
    my $parts_name_count = $item<parts> ?? $item<parts>.map(*<have>.Hash<name>).map(*.elems).sum !! 0;
    my $count = $item<have>.Hash<count>;
    my $name_count = $item<have>.Hash<name>.elems;
    if $parts_count + $count != $parts_name_count + $name_count {
        die "parse failed: count != name_count: $parts_count + $count != $parts_name_count + $name_count"
    }

    if $item<parts> {
        for $item<parts> -> $item_part {
            fill_key($item, $item_part);
            my $res = gen_resource_vm($rt, $plat, $item_part);
            @items.push($res);
        }
    }

    if $item<in> {
        @items.push($plat("env", $item<in>));
    }elsif $item<where> {
        if $item<where>.hash<region> {
            @items.push($plat("region", $item<where>.hash<region>))
        }
    }

    @items;

}

sub fill_key(Hash $item, Hash $item_part) {
  my @fill_key = <meta network sec-group image>;
  my %h;
  my %item_values = $item<values>.Array.Hash;
  my %item_part_values = $item_part<values>.Array.Hash;
  for @fill_key -> $k {
    if !%item_part_values{$k} && %item_values{$k} {
      %item_part_values.push(%( $k => %item_values{$k}))
    }
  }

  unless $item_part<in> {
    $item_part<in> = $item<in>
  }

  unless $item_part<resource_type> {
    $item_part<resource_type> = $item<resource_type>
  }

  $item_part<values>:delete;
  $item_part<values> = %item_part_values;

}

sub get_keep(Hash $config = %()) {
  state %keep;
  if !$config {
    return %keep;
  }
  if !%keep{$config<resource>} {
    %keep{$config<resource>} = %($config<name> => $config<keep>);
  } else {
    %keep{$config<resource>}.push(%($config<name> => $config<keep>));
  }

  %keep
}

sub get_provider_config($plat, $in) {
  my $content = "";
  gen($plat("provider", $in), $content, 0);
  $content;
}

multi sub remote_config(Str $plat, Str $bis, $env) {
  my $prefix = $env ?? "terraform-state/$plat/$bis/$env" !! "terraform-state/$plat/$bis"; 
  qq[
terraform \{
  backend "consul" \{
  \}
\}
  ]
}

multi sub remote_config(Str $plat) {
  my $prefix = "terraform-state/$plat"; 
  qq[
terraform \{
  backend "consul" \{
  \}
\}
  ]
}

proto parse_config(|) is export { * }
multi sub parse_config(Hash $config) {
  try {
    #my $res = remote_config($config<plat>, $config<bis>, $config<env>) ~ "\n" ~ get_resource_vm_item($config).flat.unique.join("\n");
    my $rc = remote_config($config<plat>, $config<bis>, $config<env>);
    my @res = get_resource_vm_item($config).flat.unique.push($rc);
    return %(st => 0, msg => @res, keep => get_keep );
    CATCH {
      default {
        return %(st => 1, msg => $_.message );
      }
    }
  }
}

multi sub parse_config(Positional:D $config) {
  try {
    my @res;
    my @plat;
    for |$config  {
        @plat.push($_<plat>);
        @res.push(get_resource_vm_item($_).flat.unique);
    }

    my @remote_configs = @plat.unique.map(-> $x {remote_config($x)});
    @res = @res>>.List.flat.unique;
    @res.append(|@remote_configs);
    return %(st =>0, msg => @res,  keep => get_keep );
    CATCH {
      default {
        return %(st => 1, msg => $_.message );
      }
    }
  }
}

multi sub parse_config("data_resource", Hash $config) {
    try {
        #("data_resource", "sec-group", :$return, :$data_resource)
        my $plat = get_plat($config<plat>, "data_resource");

        my $res = $plat("data_resource", $config<data_resource_expr><type>, |%(return => $config<return>,
                data_resource => $config<data_resource_expr><data_resource>) );
        return %(st =>0, msg => $res);
        CATCH {
            default {
                return %(st => 1, msg => $_.message );
            }
        }
    }
}

multi sub parse_config("secgroup", Hash $config) {
  try {
    my $plat = get_plat($config<plat>, $config<resource_type>);
    my $plat_config = $plat("secgroup", $config);
    my $content = "";
    my $depth = 0;
    my $start = $plat("start", $plat_config<config><name>);
    gen($plat_config<config>, $content, $depth);
    my $end = $plat("end");
    return %(st =>0, msg => %( config => $start ~  $content ~ $end ~ "\n", output => $plat_config<output>));
    CATCH {
      default {
        return %(st => 1, msg => $_.message );
      }
    }
  }
}

multi sub parse_config("secgroup_rule", Hash $config) {
  try {
    my $plat = get_plat($config<plat>, $config<resource_type>);
    $config<resource_type>:delete;
    my $res = "";
    for $config.kv -> $k,$v {
      my $plat_config := $plat($k, $v);
      for $plat_config -> $x {
        next if !$x<name>;
        my $content = "";
        my $depth = 0;
        my $start = $plat("start", $x<name>);
        $x<name>:delete;
        gen($x, $content, $depth);
        my $end = $plat("end");
        $res = $res ~ $start ~ $content ~ $end ~ "\n";
      }
    }

    return %(st=>0, msg=> $res);
    CATCH {
      default {
        return %(st=>1, msg => $_.message);
      }
    }

  }
}


multi sub parse_config("disk", Hash $config) {
  parse_config("base", $config, True)
}

multi sub parse_config("interface_attach", Hash $config) {
  try {
    my $plat = get_plat($config<plat>, $config<resource_type>);
    return %(st => 0,  msg => $plat("interface_attach", $config) );
    CATCH {
      default {
        return %(st => 1, msg => $_.message );
      }
    }
  }
}

multi sub parse_config("disk_attach", Hash $config) {
  try {
    my $plat = get_plat($config<plat>, "disk_attach");
    return %(st => 0, msg => $plat($config));
    CATCH {
      default {
        return %(st => 1, msg => $_.message );
      }
    }
  }
}

multi sub parse_config("lb", Hash $config) {
  parse_config("base", $config, True)
}

multi sub parse_config("lb_listener", Hash $config) {
  parse_config("base", $config)
}

multi sub parse_config("lb_server_group", Hash $config) {
  parse_config("base", $config, True)
}

multi sub parse_config("lb_attach", Hash $config) {
  parse_config("base", $config)
}

multi sub parse_config("lb_rule", Hash $config) {
  parse_config("base", $config)
}

multi sub parse_config("lb_acl", Hash $config) {
  parse_config("base", $config)
}

multi sub parse_config("network", Hash $config) {
  parse_config("base", $config, True)
}

multi sub parse_config("network_subnet", Hash $config) {
  parse_config("base", $config, True)
}

multi sub parse_config("pvzone_record", Hash $config) {
  #say parse_config("base", $config);
  parse_config("base", $config);
}

multi sub parse_config("servergroup", Hash $config) {
  parse_config("base", $config, True)
}

multi sub parse_config("eip", Hash $config) {
  parse_config("base", $config)
}

multi sub parse_config("base", Hash $config, Bool $sieffect = False) {
  try {
    my $plat = get_plat($config<plat>, $config<resource_type>);
    my $content = "";
    my $depth = 0;
    my $start = $plat("start", $config<name>);
    for $config.kv -> $k, $v {
      gen($plat($k, $v), $content, $depth);
    }
    my $end = $plat("end");
    return $sieffect ?? %(st => 0, msg => %(config => $start ~ $content ~ $end ~ "\n", output => $plat("sieffect", $config<name>) ))
                     !! %(st => 0, msg => $start ~ $content ~ $end ~ "\n" );
    CATCH {
      default {
        return %(st => 1, msg => $_.message );
      }
    }
  }
}
