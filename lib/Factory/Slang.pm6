use nqp;
use QAST:from<NQP>;
use Factory::Call;
use Tf::Grammar;
use Tf::Actions;
use TfState::v2::Grammar;
use TfState::v2::Actions;
use JSON::Tiny;
use Factory::Factory;
use Factory::Argsmap;

sub get_render_config($config = "") {
  state @config;
  if ( $config ne "") { @config.append(|$config) };
  @config.flat.unique
}

sub get_keep($config = "") {
  state %keep;
  if ( $config ne "") { %keep = $config };
  %keep
}

sub Factory::Slang::desc_exec($res) is export {
  my %res = parse_config($res);
  if %res<st> != 0 {
    say %res<msg>;
    exit 1;
  }

  get_render_config(%res<msg>);
  get_keep(%res<keep>);
  spurt "main.tf", %res<msg>, :append;
  get_names.map(-> $x {$x.split(".")[0]}).Array;

  #say %res<msg><names>.map(->$x {$x.flat}).map(-> $x { gather for $x.Array { take $_.hash<name>}}).flat;
  #say 111;
}

sub desc_call(*@res) is export {
  for @res -> $x {
    my %res = parse_config($x);
    if %res<st> != 0 {
      say %res<msg>;
      exit 1;
    }
    get_render_config(%res<msg>);
    spurt "main.tf", %res<msg>, :append;
  };
}

sub Factory::Slang::desc($res) is export {
    get_names($res);
    $res.hash;
}

sub get_names(Hash $res = %()) {
  state @names;
  if $res {
    @names.append(|$res<have>.hash<name>.cache.Array.flat);
    @names.append(|$res<parts>.map(-> $x { $x<have>.hash<name>.cache.Array}).flat);
  }
  @names.grep(Str);
}

sub Factory::Slang::depend_slang($res) is export {
  $res;
}

sub Factory::Slang::desc_network($res, $block?) is export {
  my %config = get_parse_config($res, True);
  if !defined $block {
    return %config<msg><output>;
  }


  $block(%config<msg><output>);
}

sub Factory::Slang::desc_network_subnet($res) is export {
  my %config = get_parse_config($res, True);
  %config<msg><output>;
}

sub Factory::Slang::desc_secgroup($res) is export {
  my %config = get_parse_config($res, True);
  %config<msg><output>;
}

sub Factory::Slang::desc_secgroup_rule($res) is export {
  get_parse_config($res);
}

sub Factory::Slang::desc_disk($res) is export {
  my %config = get_parse_config($res, True);
  %config<msg><output>;
}

sub Factory::Slang::desc_lb($res) is export {
  my %config = get_parse_config($res, True);
  %config<msg><output>;
}

sub Factory::Slang::desc_lb_listener($res) is export {
  get_parse_config($res);
}

sub Factory::Slang::desc_lb_server_group($res) is export {
  my %config = get_parse_config($res, True);
  %config<msg><output>;
}

sub Factory::Slang::desc_lb_rule($res) is export {
  get_parse_config($res);
}

sub Factory::Slang::desc_lb_acl($res) is export {
  get_parse_config($res)
}

sub Factory::Slang::desc_pvzone_record($res) is export {
  get_parse_config($res)
}

sub Factory::Slang::data_resource($res) is export {
  my %res = parse_config("data_resource", $res);
  if %res<st> != 0 {
    say %res<msg>;
    exit 1;
  }

  get_render_config(%res<msg><config>);
  spurt "main.tf", %res<msg><config>, :append;
  %res<msg><output>;
}


sub Factory::Slang::interface_attach($res) is export {
  get_parse_config($res)
}

sub Factory::Slang::disk_attach($res) is export {
  get_parse_config($res)
}

sub Factory::Slang::lb_attach($res) is export {
  get_parse_config($res)
}

sub Factory::Slang::desc_servergroup($res) is export {
  my %config = get_parse_config($res, True);
  %config<msg><output>;
}

sub Factory::Slang::desc_eip($res) is export {
  get_parse_config($res)
}

sub get_parse_config(Hash $config, Bool $sieffect = False) {
  my %res = parse_config($config<resource_type>, $config);
  if %res<st> != 0 {
    say %res<msg>;
    exit 1;
  }

  if $sieffect {
    get_render_config(%res<msg>);
    spurt "main.tf", %res<msg><config>, :append;
  }else{
    get_render_config(%res<msg>);
    spurt "main.tf", %res<msg>, :append;
  }

  %res
}

sub Factory::Slang::data(%args, %h) is export {
  %args.push(%h);
  %args;
}

sub Factory::Slang::image(@a, $as) is export {
  %(args => @a, :$as);
}

sub iter($prefix_name, *@args) is export {
  %(prefix => $prefix_name, names => iter_base($prefix_name, @args));
}

sub iter_suffix($prefix, $suffix, *@args) is export {
  my $prefix_names = iter_base($prefix, @args);
  %(:$prefix, names => $prefix_names.map(-> $x {$x ~ ".$suffix"}));
}

sub iter_base($name, @args) {
  my @add_args;
  my @remove_args;
  for @args -> $v {
    given $v {
      when * > 0 {
        @add_args.push($v)
      }
      when * < 0 {
        @remove_args.push($v.abs)
      }
    }
  }

  my @res_args = (@add_args.unique (-) @remove_args.unique).keys;
  $name X~ @res_args.map(-> $x {sprintf("%03d", $x)});
}

sub EXPORT(|) {
  role Factory::Slang::Grammar {

    token scope_declarator:sym<as> { <sym> <scoped('my')> }

    rule statement_control:sym<desc_exec> {
      $<sym>='descs'  '(' <desc_exec> ')' <scope_declarator>?
    }

    rule desc_exec {
      <term>* % <desc_end>
    }

    rule desc_end { 'end' 'desc' ','}

    rule term:sym<desc_vm> {
      $<sym>='desc'
      $<resource_type>='vm'
      <of_expr>
      <in_expr>?
      <have_expr>
      <plat_expr>
      <values_expr>
      <keep_expr>?
      <where_expr>?
      <with_part_expr>?
    }

    #plat "aliyun" name "test" values cidr => "10.0.0.0/24";
    rule term:sym<desc_network> {
      $<sym>='desc'
      $<resource_type>='network'
      <in_expr>?
      <plat_expr>
      <name_expr>
      <values_expr>?
      <where_expr>?
      <network_block>?
      #<pblock>?
      #<network_with_subnet_expr>?
    }

    rule network_block { 'subnets' <pblock>  <scope_declarator> }

    rule term:sym<desc_network_subnet> {
      $<sym>='desc'
      $<resource_type>='network_subnet'
      <in_expr>?
      <plat_expr>
      <name_expr>
      <bind_expr>
      <values_expr>
      <where_expr>?
    }

    rule term:sym<desc_lb> {
      $<sym>='desc'
      $<resource_type>='lb'
      <in_expr>?
      <plat_expr>
      <name_expr>
      <values_expr>
      <where_expr>?
      <scope_declarator>
    }

    rule term:sym<desc_lb_listener> {
      $<sym>='desc'
      $<resource_type>='lb_listener'
      <in_expr>?
      <plat_expr>
      <name_expr>
      <bind_expr>
      <values_expr>
    }

    rule term:sym<desc_lb_server_group> {
      $<sym>='desc'
      $<resource_type>='lb_server_group'
      <in_expr>?
      <plat_expr>
      <name_expr>
      <bind_expr>
      <values_expr>
      <scope_declarator>
    }

    rule term:sym<desc_lb_rule> {
      $<sym>='desc'
      $<resource_type>='lb_rule'
      <in_expr>?
      <plat_expr>
      <name_expr>
      <bind_expr>
      <values_expr>
    }

    rule term:sym<desc_lb_acl> {
      $<sym>='desc'
      $<resource_type>='lb_acl'
      <in_expr>?
      <plat_expr>
      <name_expr>
      <values_expr>
    }

    token resource_type { 'vm' || 'network'}
    rule of_expr { 'of' <EXPR> }
    rule in_expr { 'in' <EXPR> }
    rule have_expr { 'have' <EXPR> }
    rule plat_expr { 'plat' <EXPR> }
    rule values_expr { 'values' <EXPR> }
    rule keep_expr { 'keep' <EXPR> }
    rule where_expr { 'where' <EXPR> }
    rule with_part_expr { 'with' 'part' <part_expr>+ % ',' }
    rule part_expr { <have_expr> <values_expr> <where_expr>? 'end' }


    rule term:sym<desc_disk> {
      $<sym> = 'desc'
      $<resource_type>='disk'
      <plat_expr>
      <name_expr>
      <values_expr>
      <where_expr>?
      <scope_declarator>
    }

    rule term:sym<desc_pvzone_record> {
      $<sym> = 'desc'
      $<resource_type> = 'pvzone_record'
      <plat_expr>
      <name_expr>
      <bind_expr>
      <values_expr>
    }

    rule term:sym<disk_attach> {
      <sym>
      <plat_expr>
      <in_expr>?
      <name_expr>?
      <bind_expr>
      <values_expr>
    }

    #interface_attach plat "openstack" in $env name "test" bind "test-1" values network_id = "111-111";
    rule term:sym<interface_attach> {
      <sym>
      <plat_expr>
      <in_expr>?
      <name_expr>?
      <bind_expr>
      <values_expr>
    }

    rule term:sym<lb_attach> {
      <sym>
      <plat_expr>
      <in_expr>?
      <name_expr>?
      <bind_expr>
      <values_expr>
    }

    rule term:sym<desc_secgroup> {
      $<sym>='desc'
      $<resource_type>='secgroup'
      <plat_expr>
      <name_expr>
      <values_expr>
      <scope_declarator>
    }

    rule term:sym<desc_servergroup> {
      $<sym>='desc'
      $<resource_type>='servergroup'
      <plat_expr>
      <name_expr>
      <values_expr>
      <scope_declarator>
    }


    rule bind_expr { 'bind' <EXPR> }
    rule name_expr { 'name' <EXPR> }
    rule term:sym<desc_secgroup_rule> {
      $<sym>='desc'
      $<resource_type>='secgroup_rule'
      <plat_expr>
      <bind_expr>
      'rules'
      '=>'
      <secgroup_rule>
    }

    rule secgroup_rule { '{' <secgroup_rule_expr>* %% ';' '}'}

    rule secgroup_rule_expr {
        <secgroup_expr_list> '=>' <secgroup_action>
    }

    token secgroup_action { 'accept' || 'deny' }
    rule secgroup_expr_list { <secgroup_expr>* % ',' }
    proto rule secgroup_expr { * }
    rule secgroup_expr:sym<ingress> { <sym> <parenthes_expr> }
    rule secgroup_expr:sym<secgroup> { <sym> <parenthes_expr> }

    rule parenthes_expr {
      '(' ~ ')' <EXPR>
    }

    rule term:sym<desc_eip> {
      $<sym>='desc'
      $<resource_type>='eip'
      <plat_expr>
      <name_expr>
      <values_expr>
    }

    #data of image("aaa") as "ss" in "env" plat "sss"
    rule term:sym<data_or_resource> {
      $<sym> = ['data'|'resource']
      'of'
      <data_resource_expr>
      'return'
      <ident_val>
      <scope_declarator>
      <in_expr>?
      <plat_expr>?
    }

    token data_resource_expr {
        <data_resource> <parenthes_expr>
    }

    rule data_resource {
      'image' || 'sec_group' || 'network' || 'lb' || 'lb_server_cert'
       || 'vpc' || 'vswitch'
    }

    token ident_val {
      '"' $<val>=<[\w\-]>+ '"'
    }

    rule type_declarator:sym<def> {
      :my $*IN_DECL := 'def';
      <sym>
      [
        | '\\'? <defterm>
        | <?>
      ]
      {
        $*IN_DECL := '';
        $*W.push_lexpad($/);
      }
       <initializer>
    }

    rule statement_control:sym<depend> {
      <sym> '(' <arglist> ')' <dependlist_or_block>
    #<dependlist_or_block>
    }

    rule dependlist_or_block {
      [
        || '>>' <dependlist>
        || '=>' '{' ~ '}' <dependlist_block>
      ]
    }

    rule dependlist_block { <dependlist>* %% ';' }
    rule dependlist { <dependterm>* % '>>' }
    proto rule dependterm { * }
    rule dependterm:sym<network> {
      <sym> '(' ~ ')' <EXPR>
    }

    rule dependterm:sym<image> {
      <sym> '(' ~ ')' <EXPR>
    }

  }

  role Factory::Slang::Actions {
    sub lk(Mu \h, \k) {
      nqp::atkey(nqp::findmethod(h, 'hash')(h), k)
    }

    sub sinkit(Mu $past is raw) {
      QAST::Want.new(
              $past,
              'v', QAST::Op.new( :op('p6sink'), $past )
              )
    }

    method term:sym<desc_lb>(Mu $/) {
      my $hash := term_base($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value("lb")));
      my $qast := QAST::Stmts.new();
      my $qvar := lk(lk($/, "scope_declarator"), "scoped").ast;
      $qast.push: sinkit QAST::Op.new(
              :op<bind>,
              $qvar,
              QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_lb>, $hash)
              );
      make $qast;
    }

    method term:sym<desc_lb_listener>(Mu $/) {
      my $hash := attach($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value("lb_listener")));
      make QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_lb_listener>, $hash);
    }

    method term:sym<desc_lb_server_group>(Mu $/) {
      my $hash := attach($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value("lb_server_group")));
      my $qast := QAST::Stmts.new();
      my $qvar := lk(lk($/, "scope_declarator"), "scoped").ast;
      $qast.push: sinkit QAST::Op.new(
              :op<bind>,
              $qvar,
              QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_lb_server_group>, $hash)
              );
      make $qast;
    }

    method term:sym<desc_lb_rule>(Mu $/) {
      my $hash := attach($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value("lb_rule")));
      make QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_lb_rule>, $hash);
    }

    method term:sym<desc_lb_acl>(Mu $/) {
      my $hash := term_base($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value("lb_acl")));
      make QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_lb_acl>, $hash);
    }

    method term:sym<desc_pvzone_record>(Mu $/) {
      my $hash := attach($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value("pvzone_record")));
      make QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_pvzone_record>, $hash);
    }

    method term:sym<lb_attach>(Mu $/) {
      my $hash := attach($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value("lb_attach")));
      make QAST::Op.new(:op<call>, :name<&Factory::Slang::lb_attach>, $hash);
    }

    method term:sym<disk_attach>(Mu $/) {
      my $hash := attach($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value("disk_attach")));
      make QAST::Op.new(:op<call>, :name<&Factory::Slang::disk_attach>, $hash);
    }

    method term:sym<interface_attach>(Mu $/) {
      my $hash := attach($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value("interface_attach")));
      make QAST::Op.new(:op<call>, :name<&Factory::Slang::interface_attach>, $hash);
    }

    sub attach(Mu $/) {
      my $hash := term_base($/);
      $hash.push(QAST::SVal.new(:value("bind")));
      $hash.push(lk(lk($/, "bind_expr"), "EXPR").ast);
      $hash;
    }

    sub term_base(Mu $/) {
      my $hash := QAST::Op.new( :op<hash> );
      if lk($/, "name_expr") {
        $hash.push(QAST::SVal.new(:value("name")));
        $hash.push(lk(lk($/, "name_expr"), "EXPR").ast);
      }
      $hash.push(QAST::SVal.new(:value("plat")));
      $hash.push(lk($/, "plat_expr").ast);

      if lk($/, "in_expr") {
        $hash.push(QAST::SVal.new(:value("in")));
        $hash.push(lk($/, "in_expr").ast);
      }

      $hash.push(QAST::SVal.new(:value("values")));
      $hash.push(lk($/, "values_expr").ast);
      $hash;
    }

    method term:sym<desc_disk>(Mu $/) {
      my $hash := term_base($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value(lk($/, "resource_type").Str)));

      if lk($/, "where_expr") {
        $hash.push(QAST::SVal.new(:value("where")));
        $hash.push(lk($/, "where_expr").ast);
      }

      my $qast := QAST::Stmts.new();
      my $qvar := lk(lk($/, "scope_declarator"), "scoped").ast;
      $qast.push: sinkit QAST::Op.new(
              :op<bind>,
              $qvar,
              QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_disk>, $hash)
              );

      make $qast;
    }

    method term:sym<desc_secgroup>(Mu $/) {
      my $hash := term_base($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value(lk($/, "resource_type").Str)));

      my $qast := QAST::Stmts.new();
      my $qvar := lk(lk($/, "scope_declarator"), "scoped").ast;
      $qast.push: sinkit QAST::Op.new(
              :op<bind>,
              $qvar,
              QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_secgroup>, $hash)
              );

      make $qast;
    }

    method term:sym<desc_secgroup_rule>(Mu $/) {
      my $hash := QAST::Op.new( :op<hash> );
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value(lk($/, "resource_type").Str)));
      $hash.push(QAST::SVal.new(:value("plat")));
      $hash.push(lk($/, "plat_expr").ast);
      $hash.push(QAST::SVal.new(:value("rules")));
      $hash.push(lk($/, "secgroup_rule").ast);
      make QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_secgroup_rule>, $hash);
    }

    method secgroup_rule(Mu $/) {
      my $rl := QAST::Op.new( :op<list> );
      $rl.push($_.ast) for |lk($/, "secgroup_rule_expr");
      make $rl;
    }

    method secgroup_rule_expr(Mu $/) {
      my $hash := QAST::Op.new(:op<hash>);
      $hash.push(lk($/, "secgroup_action").ast);
      $hash.push(lk($/, "secgroup_expr_list").ast);
      make $hash;
    }

    method secgroup_action(Mu $/) {
      make QAST::SVal.new(:value($/.Str));
    }

    method secgroup_expr_list(Mu $/) {
      my $expr_list := QAST::Op.new(:op<list> );
      $expr_list.push($_.ast) for |lk($/, "secgroup_expr");
      make $expr_list;
    }

    method secgroup_expr:sym<ingress>(Mu $/) {
      my $hash := QAST::Op.new( :op<hash> );
      $hash.push(QAST::SVal.new(:value("type")));
      $hash.push(QAST::SVal.new(:value("ingress")));
      $hash.push(QAST::SVal.new(:value("value")));
      $hash.push(lk($/, "parenthes_expr").ast);
      make $hash;
    }

    method secgroup_expr:sym<secgroup>(Mu $/) { make lk($/, "parenthes_expr").ast }
    method parenthes_expr(Mu $/) {
      make lk($/, "EXPR").ast;
    }

    method term:sym<desc_servergroup>(Mu $/) {
      my $hash := term_base($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value(lk($/, "resource_type").Str)));

      my $qast := QAST::Stmts.new();
      my $qvar := lk(lk($/, "scope_declarator"), "scoped").ast;
      $qast.push: sinkit QAST::Op.new(
              :op<bind>,
              $qvar,
              QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_servergroup>, $hash)
              );

      make $qast;
    }

    method term:sym<desc_eip>(Mu $/) {
      my $hash := term_base($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value(lk($/, "resource_type").Str)));

      make QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_eip>, $hash);
    }

    method statement_control:sym<depend>(Mu $/) {
       #say lk($/,"dependlist").ast.dump;

      make QAST::Op.new(:op<call>, :name<&Factory::Slang::depend_slang>, lk($/, "dependlist_or_block").ast);

    }

    method dependlist_or_block(Mu $/) {
      my $depends := QAST::Op.new( :op<list> );

      if lk($/, "dependlist") {
        $depends.push(lk($/, "dependlist").ast);
      }

      if lk($/, "dependlist_block") {
        $depends.push(lk($/, "dependlist_block").ast);
      }
      make $depends;
    }

    method dependlist_block(Mu $/) {
      my $db := QAST::Op.new( :op<list> );
      $db.push($_.ast) for |lk($/, "dependlist");
      make $db;
    }

    method dependlist(Mu $/) {
      my $depends := QAST::Op.new( :op<list> );
      $depends.push($_.ast) for |lk($/, "dependterm");
      make $depends;
    }

    method dependterm:sym<network>(Mu $/) {
      make lk($/, "EXPR").ast;
    }

    method dependterm:sym<image>(Mu $/) {
      make lk($/, "EXPR").ast;
    }

    method type_declarator:sym<def>(Mu $/) {
      my $W := $*W;
      my $value_ast := lk($/, "initializer").ast;
      my $sigil := '';
      my $name;
      if lk($/, "defterm") {
        $name := lk($/, "defterm").ast;
      }
      elsif lk($/,"variable") {
        $name := ~lk($/, "variable").ast;
      }


      my $Mu := $W.find_symbol: nqp::list('Mu');
      my $type := nqp::defined($*OFTYPE) ?? $*OFTYPE.ast !! $Mu;
      $value_ast.returns($type);

      my $con_block := $*W.pop_lexpad();
      my $value;
      if $value_ast.has_compile_time_value {
        $value := $value_ast.compile_time_value;
      }
      else {
        $con_block.push($value_ast);
        $con_block.annotate('BEGINISH', 1);
        my $value_thunk := $W.create_code_obj_and_add_child($con_block, 'Block');

        $value := $*W.handle-begin-time-exceptions($/, 'evaluating a constant', $value_thunk);
        $*W.add_constant_folded_result($value_ast);
        printf('');
      }

      my $cur_pad := $W.cur_lexpad();

      $W.install_package($/, [$name], ($*SCOPE || 'our'),
              'def', $/.package, $cur_pad, $value);

      $/.make: QAST::WVal.new( :value($value_ast),:returns($type) );

    }

    method statement_control:sym<desc_exec>(Mu $/) {
      #my $execs := QAST::Op.new( :op<list> );
      #say lk($/, "desc_exec").ast;
      #$execs.push(say lk($_, "term").ast.dump) for |lk($/, "desc_exec");
      #say nqp::elems(lk($/, "desc_exec"));
      if lk($/, "scope_declarator") {
        my $qast := QAST::Stmts.new();
        my $qvar := lk(lk($/, "scope_declarator"), "scoped").ast;
        $qast.push: sinkit QAST::Op.new(
                :op<bind>,
                $qvar,
                QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_exec>, lk($/, "desc_exec").ast)
                );
        make $qast;
        return;
      }

      make QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_exec>, lk($/, "desc_exec").ast);
    }

    method desc_exec(Mu $/) {
        #my $execs := QAST::Op.new( :op<call>, :name<&Factory::Slang::desc_exec_items> );
        my $execs := QAST::Op.new( :op<list> );

        for |lk($/, "term") {
          $execs.push($_.ast);
        };
        make $execs;
    }

    method term:sym<desc_network>(Mu $/) {
      my $hash := term_base($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value(lk($/, "resource_type").Str)));

    #  $hash.push(QAST::SVal.new(:value("plat")));
    #  $hash.push(lk($/, "plat_expr").ast);
    #  $hash.push(QAST::SVal.new(:value("have")));
    #  $hash.push(lk($/, "have_expr").ast);

    #  if lk($/, "network_with_subnet_expr") {
    #    $hash.push(QAST::SVal.new(:value("subnets")));
    #    $hash.push(lk($/, "network_with_subnet_expr").ast);
    #  }

      if lk($/, "network_block") {
        my $stl := lk(lk($/, "network_block"), "pblock").ast;
        my $qast := QAST::Stmts.new();
        my $qvar := lk(lk(lk($/, "network_block"),"scope_declarator"), "scoped").ast;
        $qast.push: sinkit QAST::Op.new(
                :op<bind>,
                $qvar,
                QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_network>, $hash, $stl)
                );

        make $qast;
        return;
      }


      make QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_network>, $hash)
    }

    method term:sym<desc_network_subnet>(Mu $/) {
      my $hash := attach($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value(lk($/, "resource_type").Str)));

      if lk($/, "where_expr").WHAT !~~ Mu {
        $hash.push(QAST::SVal.new(:value("where")));
        $hash.push(lk($/, "where_expr").ast);
      }

      make QAST::Op.new(:op<call>, :name<&Factory::Slang::desc_network_subnet>, $hash)

    }

    method term:sym<desc_vm>(Mu $/) {
      my $hash := term_base($/);
      $hash.push(QAST::SVal.new(:value("resource_type")));
      $hash.push(QAST::SVal.new(:value(lk($/, "resource_type").Str)));

      $hash.push(QAST::SVal.new(:value("bis")));
      $hash.push(lk($/, "of_expr").ast);

      $hash.push(QAST::SVal.new(:value("have")));
      $hash.push(lk($/, "have_expr").ast);

      if lk($/, "keep_expr").WHAT !~~ Mu {
        $hash.push(QAST::SVal.new(:value("keep")));
        $hash.push(lk($/, "keep_expr").ast);
      }

      if lk($/, "where_expr").WHAT !~~ Mu {
        $hash.push(QAST::SVal.new(:value("where")));
        $hash.push(lk($/, "where_expr").ast);
      }

      if lk($/, "with_part_expr").WHAT !~~ Mu {
        $hash.push(QAST::SVal.new(:value("parts")));
        $hash.push(lk($/, "with_part_expr").ast);
      }


      my $block := QAST::Op.new(
              :op<call>,
              :name<&Factory::Slang::desc>,
              $hash
              );
      make $block;
    }

    method resource_type(Mu $/) {
        my $pair := QAST::Op.new(
            :op(<callmethod>), :name('new'),
            QAST::Var.new( :name('Pair') , :scope('lexical')),
            QAST::Want.new(
                QAST::WVal.new( :value("resource_type") )
            ),
            QAST::Want.new(
                QAST::SVal.new(:value($/.Str))
            )
        );

        make QAST::SVal.new(:value($/.Str));
    }

    method of_expr(Mu $/) {
        make lk($/, "EXPR").ast;
    }

    method in_expr(Mu $/) {
        make lk($/, "EXPR").ast;
    }

    method have_expr(Mu $/) {
        make lk($/, "EXPR").ast;
    }

    method plat_expr(Mu $/) {
        make lk($/, "EXPR").ast;
    }

    method values_expr(Mu $/) {
        #my $vs := QAST::Op.new( :op<list> );
        #$vs.push($_.ast) for |lk($/, "EXPR");
        make lk($/, "EXPR").ast;
    }

    method keep_expr(Mu $/) {
        make lk($/, "EXPR").ast;
    }

    method where_expr(Mu $/) {
        make lk($/, "EXPR").ast;
    }

    method with_part_expr(Mu $/) {
      my $parts := QAST::Op.new( :op<list> );
      $parts.push($_.ast) for |lk($/, "part_expr");
      make $parts;
    }


    method part_expr(Mu $/) {
      my $hash := QAST::Op.new( :op<hash> );
      $hash.push(QAST::SVal.new(:value("have")));
      $hash.push(lk($/, "have_expr").ast);
      $hash.push(QAST::SVal.new(:value("values")));
      $hash.push(lk($/, "values_expr").ast);
      if lk($/, "where_expr").WHAT !~~ Mu {
        $hash.push(QAST::SVal.new(:value("where")));
        $hash.push(lk($/, "where_expr").ast);
      }

      make $hash;
    }


    method term:sym<data_or_resource>(Mu $/) {
        my $hash := QAST::Op.new( :op<hash> );
        $hash.push(QAST::SVal.new(:value("return")));
        $hash.push(lk($/, "ident_val").ast);
        if lk($/, "in_expr") {
            $hash.push(QAST::SVal.new(:value("in")));
            $hash.push(lk($/, "in_expr").ast);
        }

        if lk($/, "plat_expr") {
            $hash.push(QAST::SVal.new(:value("plat")));
            $hash.push(lk($/, "plat_expr").ast);
        }

        $hash.push(QAST::SVal.new(:value("data_resource_expr")));
        $hash.push(lk($/, "data_resource_expr").ast);

        #my $qvar := QAST::Var.new( :name('$bar'), :scope('lexical'), :decl('var'));
        my $qast := QAST::Stmts.new();
        my $qvar := lk(lk($/, "scope_declarator"), "scoped").ast;
        $qast.push: sinkit QAST::Op.new(
                :op<bind>,
                $qvar,
                QAST::Op.new(:op<call>, :name<&Factory::Slang::data_resource>, $hash)
                );

        make $qast;
    }

    method data_resource_expr(Mu $/) {
        my $hash := QAST::Op.new( :op<hash> );
        $hash.push(QAST::SVal.new(:value("type")));
        $hash.push(lk($/, "data_resource").ast);
        $hash.push(QAST::SVal.new(:value("data_resource")));
        $hash.push(lk(lk($/, "parenthes_expr"), "EXPR").ast);
        make $hash;
    }

    method data_resource(Mu $/) {
        make QAST::SVal.new(:value($/.Str));
    }

    method ident_val(Mu $/) {
      #$/<val>.Str;
      make QAST::SVal.new(:value(lk($/,"val").Str));
    }

  }

  INIT { unlink("main.tf") }
  END {
    unlink("main.tf");
    my @res = get_render_config();
    if @res {
      spurt "main.tf", @res.join("\n");
      spurt "main.tf", tf(@res.join("\n"));
    }
  }
  $*LANG.refine_slang: "MAIN", Factory::Slang::Grammar, Factory::Slang::Actions;
  {}
};

sub tf($config) {
    #shell "terraform init @*ARGS[1..*].join(' ')";
  #shell "terraform workspace new @*ARGS[0]";
  #shell "terraform workspace select @*ARGS[0]";
  #shell "terraform refresh";
  #my $out = shell "terraform show -no-color", :out;
  #my %state = parse_state($out.out.slurp(:close));
  my %state = parse_state("state2".IO.slurp);
  my %hcl = parse_hcl($config);
  my %res;

  my %keep = fix_keep(%hcl<provider>.keys()[0]);
say %keep;
  #merge(%hcl<resource>, %state<resource>, %res, get_keep);
    merge(%hcl<resource>, %state<resource>, %res, %keep);
  #my $depth = 4;
  #my $res = "  terraform \{\n    backend \"%hcl<terraform><backend>.keys()[0]\" \{\n";
  #gen(%hcl<terraform><backend>.values()[0], $res, $depth);
  #$res = $res ~ "    \}\n  \}\n\n";
  my $depth = 2;
    my $res ="";
  $res = $res ~ "  provider \"%hcl<provider>.keys()[0]\" \{\n";
  gen(%hcl<provider>.values()[0], $res, $depth);
  $res = $res ~ "  \}\n\n";
  $depth = 0;

  gen(%(resource => %res), $res, $depth);

  $res;
}

sub parse_state(Str $config) {
  my $tfstate_actions =  TfState::v2::Actions.new;
  #TfState::Grammar.parse($config, :actions($tfstate_actions)).made;
  TfState::v2::Grammar.parse($config, :actions($tfstate_actions)).made;
  #TfState::Grammar.parse("state".IO.slurp, :actions($tfstate_actions)).made;
}

sub parse_hcl(Str $config) {
  my $tf_actions = Tf::Actions.new;
  Tf::Grammar.parse($config, :actions($tf_actions)).made;
}


sub fix_keep(Str $provider) {
  return get_keep unless %args_map{$provider}:exists;
  my %config = %args_map{$provider};
  my %res = %();

  for get_keep.kv -> $k, $v {
    if %config{$k}:exists {
      my %tmp = %();
      for $v.kv -> $name, $keep {
        %tmp{$name} = $keep.map(-> $x {%config{$k}{$x}:exists ?? %config{$k}{$x} !! $x}).Array;
      }
      %res{$k} = %tmp;
    }else{
      %res{$k} = $v;
    }
  }
  %res
}

#{alicloud_instance => {upload001 => [aa ss], upload002 => [aa ss]}}
sub merge(Associative:D $hcl, Associative:D $state, Associative:D $res, $keep = "") {
  my %tmp;
  for $hcl.kv -> $k, $v {
    if !($state{$k}:exists) {
      $res{$k} = $v;
      next
    }

    given $v {
      when Associative:D {
        $res{$k} = {}
        if $keep{$k}:exists {
            merge($hcl{$k}, $state{$k},$res{$k}, $keep{$k});
        }else{
          merge($hcl{$k}, $state{$k},$res{$k});
        }
      }

      when Positional:D {
        if $v eqv $state{$k} {
          $res{$k} = $v;
        } else {
          $res{$k} = $state{$k};
        }
      }
      default {
        if $k eq any($keep.Array) {
          $res{$k} = $v;
        }else {
          if $v ne $state{$k} {
            $res{$k} = $state{$k};
          } else {
            $res{$k} = $v;
          }
        }
      }
    }
  }
  $res;

}