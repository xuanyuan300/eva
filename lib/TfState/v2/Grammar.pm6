unit grammar TfState::v2::Grammar;

token TOP {
    <.eol>* <block> <.eol>*
}

rule key_multi { <key1> || <key2> || <key3> }
rule key1 { <key> $<resource_type>=<str> $<resource_name>=<str> }
rule key2 { <key> <str> }
rule key3 { <key_str> }

rule value_multi { <value1> | <value2> | <value3> }
rule value1 { <key_str> <.eol>* }
rule value2 { '{' <.eol>* <block> '}' <.eol>* }
rule value3 { '[' <.eol>* <key_str>* %% ',' <.eol>* ']' }

rule block {
    :my %*resource;
    [<block1> | <block2>]*
}

rule block1 { <key_multi> <.eol>* <value_multi> <.eol>* }
rule block2 { <key_multi> \h* '=' \h* <value_multi> <.eol>* }

token key_str { <key>|<str>}

token str {
    '"' ~ '"' $<v>=<[+\w.\-${}\[\],\s:/=*]>+
}

token key { <[\w\-]>+ }

token eol {  [ <[#]> \N* ]? \n  }
