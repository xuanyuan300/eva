unit class Tf::Actions;

#`[
  method TOP($/) {
    my %res;
    for $<block>>>.made {
      for $_.kv -> $k, $v {
        if $k eq "resource" {
          for $_{"resource"}.kv -> $r, $rv {
            if !%res{$k}{$r} {
              %res{$k}{$r} = $rv;
            } else {
              %res{$k}{$r}.push($rv.hash);
            }
          }
        }else {
          if !%res{$k} {
            %res{$k} = $v;
          } else {
            %res{$k}.push($v.hash);
          }
        }
      }
    }

    make %res;
  }

  method block($/) {
    my %res;
    if $<resource_type> && $<name> && $<key>.Str eq "resource" {
      %res{"resource"}{$<resource_type><v>.Str}{$<name><v>.Str} = $<kvlist>.made;
      return make %res;
    }
    if $<resource_type> {
      %res{$<key>.Str}{$<resource_type><v>.Str} = $<kvlist>.made;
      return make %res;
    }
    %res{$<key>.Str} = $<kvlist>.made;
    return make %res;
  }

  method kvlist($/) {
    my %res = make $<kv>>>.made.hash;
    if $<block>>>.made.elems() == 1 {
      %res.push($<block>>>.made[0].hash);
    }else{
      #say $<block>>>.made.perl;
      for $<block>>>.made {
        %res.push($_.hash)
      }
    }

    make %res;
  }

  method kv($/) {
    make %($<key>.Str => $<value>.made);
  }

  method value($/) {
    if $<str> {
      return make $<str>.made;
    }

    if $<array> {
      return make $<array>.made;
    }
  }

  method array($/) {
    make $<str>>>.made
  }

  method str($/) {
    make $<v>.Str;
  }
]

method TOP($/) {
    my %block = $<block>.made;
    #say %block;
    my %res;
    for %block.kv -> $k, $v {
        my @th = $k.split("|").Array;
        if @th.elems == 3 {
            if !%res{@th[0]}{@th[1]} {
                %res{@th[0]}{@th[1]} = %(@th[2] => $v)
            }else{
                %res{@th[0]}{@th[1]}.push(%(@th[2] => $v))
            }
        }
        if @th.elems == 2 {
            if !%res{@th[0]} {
                %res{@th[0]} = %(@th[1] => $v)
            }else{
                %res{@th[0]}.push(%(@th[1] => $v))
            }
        }
        if @th.elems == 1 && @th[0] eq "terraform" {
            for $v.kv -> $kk, $vv {
                %res{@th[0]} = ([=>] $kk.split("|").Array.push($vv)).hash;
            }
        }


    }
    make %res;
}

method block($/) {
    if $<block1> {
        return make %*resource;
    }
    if $<block2> {
        make %*resource;
            #return make $<block2>>>.made;
    }
}

method block1($/) {
    %*resource.push(%($<key_multi>.made => $<value_multi>.made));
    make %*resource;
        #make %($<key_multi>.made => $<value_multi>.made);
}

method block2($/) {
    %*resource.push(%($<key_multi>.made => $<value_multi>.made));
    make %*resource;
        #make %($<key_multi>.made => $<value_multi>.made);
}

method value_multi($/) {
    if $<value1> {
        return make $<value1><value_str>.made;
    }

    if $<value2> {
        return make $<value2><block>.made;
    }

    if $<value3> {
        return make $<value3><value_str>>>.made;
    }
}

method key_multi($/) {
    if $<key1> {
        #say $<key1><key>.Str;
        #say $<key1><resource_type><v>.Str;
        #say $<key1><resource_name><v>.Str;
        #return make $<key1><key>.Str => $<key1><resource_type><v>.Str => $<key1><resource_name><v>.Str => %();
        return make "{$<key1><key>.Str}|{$<key1><resource_type><v>.Str}|{$<key1><resource_name><v>.Str}"
    }

    if $<key2> {
        #say $<key2><key>.Str;
        #say $<key2><str><v>.Str;
        return make "{$<key2><key>.Str}|{$<key2><str><v>.Str}"
    }

    if $<key3> {
        if $<key3><key_str><key> {
            #say $<key3><key_str><key>.Str;
            return make $<key3><key_str>.made;

        }
        if $<key3><key_str><str> {
            #say $<key3><key_str><str><v>.Str;
            return make $<key3><key_str>.made;
        }
    }
}

method key_str($/) {
    if $<key> {
        return make $<key>.Str;
    }

    if $<str> {
        return make $<str><v>.Str;
    }
}

method value_str($/) {
    if $<key> {
        return make $<key>.Str;
    }

    if $<expr_str> {
        return make $<expr_str><v>.Str;
    }
}