package MySchema::Type;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table("type");

__PACKAGE__->add_columns(
    id   => { data_type => "INTEGER" },
    type => { data_type => "TEXT" },
);

__PACKAGE__->set_primary_key("id");

1;

