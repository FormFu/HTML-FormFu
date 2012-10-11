package HTMLFormFu::MyRole;
use Moose::Role;

sub custom_role_method {
    my ( $self ) = @_;
    
    return sprintf "form ID: %s", $self->id;
}


1;
