package HTML::FormFu::Role::CustomRoles;
use Moose::Role;
use Moose::Util qw( ensure_all_roles );

use List::MoreUtils qw( uniq );

has _roles => (
    is      => 'rw',
    default => sub { [] },
    lazy    => 1,
    isa     => 'ArrayRef',
);

sub roles {
    my $self = shift;
    
    my @roles = @{ $self->_roles };
    my @new;
    
    if ( 1 == @_ && 'ARRAY' eq ref $_[0] ) {
        @new = @{ $_[0] };
    }
    elsif ( @_ ) {
        @new = @_;
    }
    
    if (@new) {
        for my $role (@new) {
            if ( !ref($role) && $role =~ s/^\+// ) {
                push @roles, $role;
            }
            elsif ( !ref $role ) {
                push @roles, "HTML::FormFu::Role::$role";
            }
            else {
                push @roles, $role;
            }
        }
        
        @roles = uniq @roles;
        
        ensure_all_roles( $self, @roles );
        
        $self->_roles(\@roles);
    }
    
    return [@roles];
}

1;
