package MySchema::Note;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table("note");

__PACKAGE__->add_columns(
    id     => { data_type => "INTEGER" },
    master => { data_type => "INTEGER" },
    note   => { data_type => "TEXT" },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to( master => 'MySchema::Master', 'id' );

1;

