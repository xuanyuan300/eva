unit class TfState::v1::Actions;

has %!res;
method TOP($/) {
  make %!res;
}

method block($/) {
  my %kv_hash = $<kv>>>.made.hash;
  if $*spec {
    for $*spec.kv -> $k,$v {
      %kv_hash{$k} = $v;
    }
  }
  $*spec = %();
  %!res{$*header_key}{$*header_value} = %kv_hash;
}

method top_key($/) {
  $*header_key = $<header_key>.Str;
  $*header_value = $<header_value>.Str;
  #say %!res{$<header_key>.Str} = %($<header_value>.Str => %());
  #make %!res{$<header_key>.Str} = %($<header_value>.Str => %());
  make %($*header_key => $*header_value);
}

method kv($/) {
  if $<key>.Str.contains("%") {
    $*spec{$<key>.Str.split(".%")[0]} = %() ;
  }elsif $<key>.Str.contains("#") {
    $*spec{$<key>.Str.split(".#")[0]} = [];
  }else{
    if $*spec{$<key>.Str.split(".")[0]}:exists {
      given $*spec{$<key>.Str.split(".")[0]} {
        when Hash {
          $*spec{$<key>.Str.split(".")[0]}{$<key>.Str.split(".")[1]} = $<value>.Str;
        }
        when Array {
          $*spec{$<key>.Str.split(".")[0]}.push($<value>.Str);
        }
      }

    }else{
      return make %($<key>.Str => $<value>.Str);
    }
  }

  make %()
}
