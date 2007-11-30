package MySchema::Band;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table("band");

__PACKAGE__->add_columns(
    id   => { data_type => "INTEGER" },
    band => { data_type => "TEXT" },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many( user_bands => 'MySchema::UserBand', 'band' );

__PACKAGE__->many_to_many( users => 'user_bands', 'user' );

1;

