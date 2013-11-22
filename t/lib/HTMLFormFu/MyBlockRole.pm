package HTMLFormFu::MyBlockRole;
use Moose::Role;
use List::Util qw( first );

around attributes     => \&_myblockrole_attrs;
around attrs          => \&_myblockrole_attrs;
around attributes_xml => \&_myblockrole_attrs;
around attrs_xml      => \&_myblockrole_attrs;

my $key   = 'class';
my $value = 'myblockrole';

sub _myblockrole_attrs {
    my $orig = shift;
    my $self = shift;
    
    if (@_) {
        return $self->$orig(@_);
    }
    
    my $attrs = $self->{attributes};
    my $done;
    
    if ( exists $attrs->{$key} ) {
        my @vals = split /\s+/, $attrs->{$key};
        
        if ( first { $_ eq $value } @vals ) {
            $done = 1;
        }
    }
    
    if ( !$done ) {
        $self->add_attrs({ $key => $value });
    }
    
    return $attrs;
};

1;
