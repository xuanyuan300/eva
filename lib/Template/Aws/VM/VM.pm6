use Factory::Slang;

unit module Template::Aws::VM;

sub desc_vm(:$az, :$region, :$count, :$name, :$values, :$eip = %()) is export {
  descs(
          desc vm of "bis"
            have state=> "online", only_ident=>True, count=> $count, name=>$name<names>
            plat "aws"
            values $values
            where az => $az, region => $region

        ) as $names;


  $names.sort;
}

sub eip(:$idx, :$name) is export {
  desc eip plat "aws" name "test-eip-$idx" values instance => "\$\{aws_instance.$name.id\}", vpc => True;
}

