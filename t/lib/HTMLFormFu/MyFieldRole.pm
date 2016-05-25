package HTMLFormFu::MyFieldRole;
use Moose::Role;

around container_attributes     => \&_myfieldrole_attrs;
around container_attrs          => \&_myfieldrole_attrs;
around container_attributes_xml => \&_myfieldrole_attrs;
around container_attrs_xml      => \&_myfieldrole_attrs;

my $key   = 'class';
my $value = 'myfieldrole';

sub _myfieldrole_attrs {
    my $orig = shift;
    my $self = shift;

    if (@_) {
        return $self->$orig(@_);
    }

    my $attrs = $self->{container_attributes};
    my $done;

    if ( exists $attrs->{$key} ) {
        my @vals = split /\s+/, $attrs->{$key};

        if ( first { $_ eq $value } @vals ) {
            $done = 1;
        }
    }

    if ( !$done ) {
        $self->add_container_attrs( { $key => $value } );
    }

    return $attrs;
}

1;
