use Factory::Slang;

unit module Template::Aliyun::VM;

sub desc_vm(:$az, :$region, :$count, :$name, :$values, :$pvzone = %(), :$single=False) is export {
  descs(
          desc vm of "bis"
            have state=> "online", count=> $count, name=>$name<names>
            plat "aliyun"
            values $values
            keep ["flavor"]
            where az => $az, region => $region

        ) as $names;

  my $end_names;
  $end_names = $single ?? ($name<names>.map(-> $x {$x.split(".")[0]})) !! $names;

  if $pvzone {
    for $end_names.Array -> $x {
      my $pvzone_values = $pvzone.hash<values>.hash.push(%(depends_on => $x, value => "\$\{alicloud_instance.{$x}.private_ip\}"));
      $pvzone_values<resource_record> = "{$x}." ~ $pvzone_values<resource_record>;
      my $zone_id = $pvzone.hash<zone_id>;
      desc pvzone_record  plat "aliyun" name "{$x}-record" bind $zone_id values $pvzone_values;
    }
  }
  $end_names.sort;
}

sub disk_attach(:$az, :$name, :$values) is export {
  desc disk plat "aliyun" name "{$name}_disk" values $values where az => $az as $diskid;
  disk_attach plat "aliyun" name "{$name}_diskattach" bind $name values disk_id => $diskid;
}
