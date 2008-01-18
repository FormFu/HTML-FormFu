package MySchema::User;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table("user");

__PACKAGE__->add_columns(
    id     => { data_type => "INTEGER" },
    master => { data_type => "INTEGER" },
    name   => { data_type => "TEXT" },
    title  => { data_type => "TEXT" },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to( master => 'MySchema::Master', 'id' );

__PACKAGE__->has_many( addresses => 'MySchema::Address', 'user' );

__PACKAGE__->has_many( user_bands => 'MySchema::UserBand', 'user' );

__PACKAGE__->many_to_many( bands => 'user_bands', 'band' );

sub fullname {
    my $self = shift;

    if (@_) {
        my $fullname = shift;
        
        my $match = qr/
            (?: ( \w+ ) \s+ )?
            ( .* )
            /x;
        
        my ($title, $name) = $fullname =~ $match;
        
        $self->set_column( 'title', $title );
        $self->set_column( 'name', $name );
        
        return $fullname;
    }
    
    my $title = $self->get_column('title');
    my $name  = $self->get_column('name');
    
    return join ' ', grep {defined} $title, $name;
}

1;

