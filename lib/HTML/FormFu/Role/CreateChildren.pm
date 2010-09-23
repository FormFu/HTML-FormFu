package HTML::FormFu::Role::CreateChildren;
use Moose::Role;

use HTML::FormFu::Util qw( _merge_hashes require_class );
use Carp qw( croak );
use Clone ();
use List::MoreUtils qw( uniq );
use Scalar::Util qw( weaken );

sub element {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_element($_) } @$arg;
    }
    else {
        push @return, $self->_single_element($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub deflator {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_deflator($_) } @$arg;
    }
    else {
        push @return, $self->_single_deflator($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub filter {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_filter($_) } @$arg;
    }
    else {
        push @return, $self->_single_filter($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub constraint {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_constraint($_) } @$arg;
    }
    else {
        push @return, $self->_single_constraint($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub inflator {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_inflator($_) } @$arg;
    }
    else {
        push @return, $self->_single_inflator($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub validator {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_validator($_) } @$arg;
    }
    else {
        push @return, $self->_single_validator($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub transformer {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_transformer($_) } @$arg;
    }
    else {
        push @return, $self->_single_transformer($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub plugin {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_plugin($_) } @$arg;
    }
    else {
        push @return, $self->_single_plugin($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub _require_element {
    my ( $self, $arg ) = @_;

    $arg->{type} = 'Text' if !exists $arg->{type};

    my $type  = delete $arg->{type};
    my $class = $type;

    if ( not $class =~ s/^\+// ) {
        $class = "HTML::FormFu::Element::$class";
    }

    $type =~ s/^\+//;

    require_class($class);

    my $element = $class->new( {
            type   => $type,
            parent => $self,
        } );

    if ( $element->can('default_args') ) {
        $element->default_args( Clone::clone( $self->default_args ) );
    }

    # handle default_args
    if ( exists $self->default_args->{elements}{$type} ) {
        $arg = _merge_hashes( $self->default_args->{elements}{$type}, $arg, );
    }

    $element->populate( $arg );

    $element->setup;

    return $element;
}

sub _single_element {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg eq 'HASH' ) {
        $arg = {%$arg};    # shallow clone
    }
    else {
        croak 'invalid args';
    }

    my $new = $self->_require_element( $arg );

    if (   $self->can('auto_fieldset')
        && $self->auto_fieldset
        && $new->type ne 'Fieldset' )
    {
        my ($target)
            = reverse @{ $self->get_elements( { type => 'Fieldset' } ) };

        push @{ $target->_elements }, $new;

        $new->{parent} = $target;
        weaken $new->{parent};
    }
    else {
        push @{ $self->_elements }, $new;
    }

    return $new;
}

sub _single_deflator {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg eq 'HASH' ) {
        $arg = {%$arg};    # shallow clone
    }
    else {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined} ( delete $arg->{name}, delete $arg->{names} );

    if ( !@names ) {
        @names = uniq
            grep {defined}
            map  { $_->nested_name } @{ $self->get_fields };
    }

    croak "no field names to add deflator to" if !@names;

    my $type = delete $arg->{type};

    my @return;

    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { nested_name => $x } ) } ) {
            my $new = $field->_require_deflator( $type, $arg );
            push @{ $field->_deflators }, $new;
            push @return, $new;
        }
    }

    return @return;
}

sub _single_filter {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg eq 'HASH' ) {
        $arg = {%$arg};    # shallow clone
    }
    else {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined} ( delete $arg->{name}, delete $arg->{names} );

    if ( !@names ) {
        @names = uniq
            grep {defined}
            map  { $_->nested_name } @{ $self->get_fields };
    }

    croak "no field names to add filter to" if !@names;

    my $type = delete $arg->{type};

    my @return;

    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { nested_name => $x } ) } ) {
            my $new = $field->_require_filter( $type, $arg );
            push @{ $field->_filters }, $new;
            push @return, $new;
        }
    }

    return @return;
}

sub _single_constraint {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg eq 'HASH' ) {
        $arg = {%$arg};    # shallow clone
    }
    else {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined} ( delete $arg->{name}, delete $arg->{names} );

    if ( !@names ) {
        @names = uniq
            grep {defined}
            map  { $_->nested_name } @{ $self->get_fields };
    }

    croak "no field names to add constraint to" if !@names;

    my $type = delete $arg->{type};

    my @return;

    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { nested_name => $x } ) } ) {
            my $new = $field->_require_constraint( $type, $arg );
            push @{ $field->_constraints }, $new;
            push @return, $new;
        }
    }

    return @return;
}

sub _single_inflator {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg eq 'HASH' ) {
        $arg = {%$arg};    # shallow clone
    }
    else {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined} ( delete $arg->{name}, delete $arg->{names} );

    if ( !@names ) {
        @names = uniq
            grep {defined}
            map  { $_->nested_name } @{ $self->get_fields };
    }

    croak "no field names to add inflator to" if !@names;

    my $type = delete $arg->{type};

    my @return;

    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { nested_name => $x } ) } ) {
            my $new = $field->_require_inflator( $type, $arg );
            push @{ $field->_inflators }, $new;
            push @return, $new;
        }
    }

    return @return;
}

sub _single_validator {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg eq 'HASH' ) {
        $arg = {%$arg};    # shallow clone
    }
    else {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined} ( delete $arg->{name}, delete $arg->{names} );

    if ( !@names ) {
        @names = uniq
            grep {defined}
            map  { $_->nested_name } @{ $self->get_fields };
    }

    croak "no field names to add validator to" if !@names;

    my $type = delete $arg->{type};

    my @return;

    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { nested_name => $x } ) } ) {
            my $new = $field->_require_validator( $type, $arg );
            push @{ $field->_validators }, $new;
            push @return, $new;
        }
    }

    return @return;
}

sub _single_transformer {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg eq 'HASH' ) {
        $arg = {%$arg};    # shallow clone
    }
    else {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined} ( delete $arg->{name}, delete $arg->{names} );

    if ( !@names ) {
        @names = uniq
            grep {defined}
            map  { $_->nested_name } @{ $self->get_fields };
    }

    croak "no field names to add transformer to" if !@names;

    my $type = delete $arg->{type};

    my @return;

    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { nested_name => $x } ) } ) {
            my $new = $field->_require_transformer( $type, $arg );
            push @{ $field->_transformers }, $new;
            push @return, $new;
        }
    }

    return @return;
}

1;
