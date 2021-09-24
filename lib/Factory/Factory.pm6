unit module Factory;

use Factory::Openstack::Openstack;
use Factory::Openstack::Servergroup;
use Factory::Aliyun::Aliyun;
use Factory::Aliyun::SecgroupRule;
use Factory::Aliyun::Secgroup;
use Factory::Aliyun::Disk;
use Factory::Aliyun::DiskAttach;
use Factory::Aliyun::Slb;
use Factory::Aliyun::SlbListener;
use Factory::Aliyun::SlbServergroup;
use Factory::Aliyun::SlbAttach;
use Factory::Aliyun::SlbRule;
use Factory::Aliyun::SlbAcl;
use Factory::Aliyun::VPC;
use Factory::Aliyun::VSwitch;
use Factory::Aliyun::PvZoneRecord;
use Factory::Aws::Aws;
use Factory::Aws::Eip;

proto get_plat(Str, Str) is export {*};

multi sub get_plat("openstack", "vm") {
    &openstack_spec;
}

multi sub get_plat("openstack", "data_resource") {
    &openstack_spec;
}

multi sub get_plat("openstack", "interface_attach") {
    &openstack_spec;
}

multi sub get_plat("openstack", "servergroup") {
    &openstack_servergroup_spec;
}

multi sub get_plat("aliyun", "vm") {
    &aliyun_spec;
}

multi sub get_plat("aliyun", "data_resource") {
    &aliyun_spec;
}

multi sub get_plat("aliyun", "secgroup") {
    &aliyun_sg_spec
}

multi sub get_plat("aliyun", "secgroup_rule") {
    &aliyun_sgr_spec;
}

multi sub get_plat("aliyun", "disk") {
    &aliyun_disk_spec
}

multi sub get_plat("aliyun", "disk_attach") {
    &aliyun_disk_attach_spec
}

multi sub get_plat("aliyun", "lb") {
    &aliyun_slb_spec
}

multi sub get_plat("aliyun", "lb_listener") {
    &aliyun_slb_listener_spec
}

multi sub get_plat("aliyun", "lb_server_group") {
    &aliyun_slb_servergroup_spec
}

multi sub get_plat("aliyun", "lb_attach") {
    &aliyun_slb_attach_spec
}

multi sub get_plat("aliyun", "lb_rule") {
    &aliyun_slb_rule_spec
}

multi sub get_plat("aliyun", "lb_acl") {
    &aliyun_slb_acl_spec
}

multi sub get_plat("aliyun", "network") {
    &aliyun_vpc_spec
}

multi sub get_plat("aliyun", "network_subnet") {
    &aliyun_vswitch_spec
}

multi sub get_plat("aliyun", "pvzone_record") {
    &aliyun_pvzone_record_spec
}

multi sub get_plat("aws", "vm") {
    &aws_spec
}

multi sub get_plat("aws", "eip") {
    &aws_eip_spec
}

proto gen(|) is export {*};

multi sub gen(Str $v) {
  '"' ~ $v ~ '"'
}

multi sub gen(Numeric $v) {
  '"' ~ $v ~ '"'
}

multi sub gen(Bool $v) {
  $v ?? "true" !! "false"
}


multi sub gen(Associative:D $h, Str $content is rw, Int $depth is rw, Associative:D $render_args=%() ) {
  #$h.flatmap({ my $v = '{' ~ .key ~ '=' ~ gen(.value) ~ '}'; $v}).join('\n');
  (temp $depth)+=2;
  my @pair_content;
  for $h.kv -> $k,$v {
    given $v {
      when Associative:D {
        #$content = "$content" ~ $k.indent($depth) ~ ' {' ~ "\n";
        my $as_content = "";
        if $render_args{"block"} {
            $as_content = $k.indent($depth) ~ ' {' ~ "\n" ~ gen($v, $as_content, $depth) ~ "\n" ~ '}'.indent($depth) ~ "\n";
        } elsif $render_args{"attr"} {
            $as_content = $k.indent($depth) ~ ' = {' ~ "\n" ~ gen($v, $as_content, $depth) ~ "\n" ~ '}'.indent($depth) ~ "\n";
        } else {
            $as_content = $k.indent($depth) ~ ' {' ~ "\n" ~ gen($v, $as_content, $depth) ~ "\n" ~ '}'.indent($depth) ~ "\n";
        }
        $content = $content ~ $as_content;
        #if @pair_content {
        #    $content = $content ~ @pair_content.join("\n");
        #}
        #$content = "$content" ~ '}'.indent($depth) ~ "\n";
      }

      when Positional:D {
        #$content = "$content" ~ $k.indent($depth) ~ " = " ~ gen($v, $k, $depth);
        $content = "$content" ~ gen($v, $k, $depth);
      }

      when Str {
         @pair_content.push($k.indent($depth) ~ " = " ~ gen($v));
      }

      when Numeric {
        @pair_content.push($k.indent($depth) ~ " = " ~ gen($v));
      }

      when Bool {
        @pair_content.push($k.ident($depth) ~ " = " ~ gen($v));
      }
    }
  }

  if @pair_content {
    $content = $content ~ @pair_content.join("\n") ~ "\n";
  }

  $content;
}

multi sub gen(Positional:D $arr, Str $k, Int $depth is rw, Associative:D $render_args=%()) {
  #'[ ' ~ $arr.flatmap(&gen).join(',') ~ ' ]';
  my $arr_content = "";
  my @arr_content;
  for $arr -> $v {
    given $v {
      when Associative:D {
        #my $content = $k.indent($depth) ~ ' {' ~ "\n";
        my $content = "";
        $content = gen($v, $content, $depth);
        $content = $k.indent($depth) ~ '{' ~ "\n" ~ $content;
        $arr_content = $arr_content ~ $content ~ "\n" ~ '}'.indent($depth) ~ "\n";
      }

      when Str {
        @arr_content.push(gen($v));
      }
    }
  }
  #$k.indent($depth) ~ '{' ~ "\n" ~ $content ~ '}' ~ "\n";

  if @arr_content {
    $arr_content = $arr_content ~ "\n" ~ $k.indent($depth) ~ " = " ~  "[ " ~ @arr_content.join(",") ~ " ]\n";
  }

  $arr_content;

}
