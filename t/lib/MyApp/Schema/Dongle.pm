package MyApp::Schema::Dongle;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ PK::Auto Core /);

__PACKAGE__->table("dongle");

__PACKAGE__->add_columns(
    "person_id",
    {   data_type   => "INT", 
        is_nullable => 0, 
        size        => 10, 
        extra => {
            unsigned => 1,
        },
    },
    "dongle",
    {   data_type   => "VARCHAR",
        is_nullable => 0,
        size        => 10,
    },
);

__PACKAGE__->set_primary_key("person_id");

__PACKAGE__->belongs_to(
    person => 'Person',
    { 'foreign.person_id' => 'self.person_id' } );

1;

