package MyApp::Schema::Person;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ PK::Auto Core /);

__PACKAGE__->table("person");

__PACKAGE__->add_columns(
    "id",
    {   data_type   => "INT", 
        is_nullable => 0, 
        size        => 10, 
        extra => {
            unsigned => 1,
        },
    },
    "title",
    {
        data_type   => "ENUM",
        is_nullable => 0,
        extra => {
            list => [qw/ Mr Mrs Miss /],
        },
    },
    "name",
    {   data_type   => "VARCHAR",
        is_nullable => 0,
        size        => 255,
    },
);

1;

