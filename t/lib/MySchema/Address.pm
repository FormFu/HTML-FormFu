package MySchema::Address;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table("address");

__PACKAGE__->add_columns(
    id        => { data_type => "INTEGER" },
    user      => { data_type => "INTEGER" },
    address   => { data_type => "TEXT" },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to( user => 'MySchema::User' );

1;

