package unicode::Schema::Unicode;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ UTF8Columns PK::Auto Core /);

__PACKAGE__->table("unicode");

__PACKAGE__->add_columns(
    "id",
    {
        data_type => "INTEGER",
        is_nullable => 0,
    },
    "string",
    {   data_type     => "VARCHAR",
        size          => 255
    },
);

__PACKAGE__->utf8_columns(qw/ string /);

__PACKAGE__->set_primary_key("id");

1;
