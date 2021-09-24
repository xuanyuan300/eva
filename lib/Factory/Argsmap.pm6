
our %args_map = %(
        alicloud => %(
                alicloud_instance => %(
                        flavor => "instance_type",
                        image => "image_id",
                        sec_group => "security_groups",
                )
        ),
        openstack => %(
                openstack_compute_instance_v2 => %(
                    flavor => "flavor_name",
                    sec_group => "security_groups",
                    image => "image_name",
                    meta => "metadata",
                )
        )
)