unit grammar Tf::Grammar;
#use JSON::Tiny;


#token TOP { <block>* }

#rule block {  <.eol>* <key> \h* $<resource_type>=<str>? \h* $<name>=<str>? \h* '{' <.eol>* <kvlist> <.eol>* '}' <.eol>* }

#rule kvlist { [<kv>|<block>]* }
#rule kv { <.eol>* <key> \h* '=' \h* <value> <.eol>* }
#
#rule value {
#  <str>|<array>
#}
#
#rule array {
#  '[' <str>* % ',' ']'
#}
#
#token str {
#  '"' ~ '"' $<v>=<[+\w.\-${}\[\],\s:/=*]>+
#}
#
#token key { <[\w\-]>* }
#
#token eol {  [ <[#]> \N* ]? \n  }


token TOP {
    <.eol>* <block> <.eol>*
}

rule key_multi { <key1> || <key2> || <key3> }
rule key1 { <key> $<resource_type>=<str> $<resource_name>=<str> }
rule key2 { <key> <str> }
rule key3 { <key_str> }

rule value_multi { <value1> | <value2> | <value3> }
rule value1 { <value_str> <.eol>* }
rule value2 { '{' <.eol>* <block> '}' <.eol>* }
rule value3 { '[' <.eol>* <value_str>* %% ',' <.eol>* ']' }

rule block {
    :my %*resource;
    [<block1> | <block2>]*
}
rule block1 { <key_multi> <.eol>* <value_multi> <.eol>* }
rule block2 { <key_multi> \s* '=' \s* <value_multi> <.eol>* }

token key_str { <key>|<str> }
token value_str { <key>|<expr_str> }

token str {
    '"' ~ '"'  $<v>=<[\w\-]>+
}

regex expr_str {
    '"' ~ '"' $<v>=<[+\w.\-${}\[\],\h():/=*"]>+
}

token key { <[\w\-]>+ }

token eol {  [ <[#]> \N* ]? \n  }
