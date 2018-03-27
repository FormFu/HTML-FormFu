package MyApp::Schema::Person;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ PK::Auto Core /);

__PACKAGE__->table("person");

__PACKAGE__->add_columns(
    "person_id",
    {   data_type   => "INT",
        is_nullable => 0,
        size        => 10,
        extra       => { unsigned => 1, },
    },
    "title",
    {   data_type   => "ENUM",
        is_nullable => 0,
        extra       => { list => [qw/ Mr Mrs Miss /], },
    },
    "name",
    {   data_type   => "VARCHAR",
        is_nullable => 0,
        size        => 255,
    },
    "age",
    {   data_type   => "INT",
        is_nullable => 0,
        size        => 10,
        extra       => { unsigned => 1, }
    },
    "is_human",
    {   data_type   => "BOOLEAN",
        is_nullable => 0,
    },
    "income",
    {   data_type   => "DECIMAL",
        is_nullable => 0,
        size        => [ 8, 2 ],
    } );

__PACKAGE__->set_primary_key("person_id");

__PACKAGE__->might_have(
    dongle => 'Dongle',
    { 'foreign.person_id' => 'self.person_id' } );

1;
