unit grammar TfState::v1::Grammar;


token TOP { <block>* }

token block {
    :my $*header_key;
    :my $*header_value;
    :my $*spec;
    <top_key> ':' <.eol>+ ^^ <kv>*
}

token top_key { <header_key> '.' <header_value> }

token kv { \h* <key> \h* '=' \h* <value> \h* <.eol>+ }
token header_key { \w+ }
token header_value { <[\w.\-]>+ }
token key { <[\w.\-#%]>* }
token value { <[\w.\-:]>* }
token eol { \n }



