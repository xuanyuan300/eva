unit module Template::Openstack::VM;
use Factory::Slang;

sub desc_vm(:$az, :$count, :$name, :$values) is export {
  desc servergroup plat "openstack" name $name<prefix> values policies => ["soft-anti-affinity"] as $sgid;
  my @values = $values.Array.append(%(schedule => %( group => $sgid)));
  descs(
          desc vm of "bis" in "$az"
            have state=> "online", count=> $count, name=>$name<names>
            plat "openstack"
            values @values
            keep ["image"]
  )
}

proto interface_attach(Str $network, $name_ip) is export { * }
multi sub interface_attach($network, Positional:D $name_ip) {
  data of network(name=>$network) return "output" as $nid plat "openstack";
  for $name_ip -> $x {
    interface_attach_decl($nid, $x)
  }
}

multi sub interface_attach($network, Hash $name_ip) {
  data of network(name=>$network) return "output" as $nid plat "openstack";
  interface_attach_decl($nid, $name_ip)
}

sub interface_attach_decl(Str $nid, Hash $name_ip) {
    interface_attach plat "openstack"  bind $name_ip<name> values
      network_id => $nid,
      fix_ip => $name_ip<ip>
}

