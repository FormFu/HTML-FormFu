package HTML::FormFu::Role::Populate;
use Moose::Role;

use Carp qw( croak );

after BUILD => sub {
    my ( $self, $args ) = @_;

    $args ||= {};
    # get args handled by Moose so they aren't set twice
    my %init_args = map { $_->{init_arg} => 1 } $self->meta->get_all_attributes;
    # remove defaults set in HTML::FormFu::BUILD because they need to be set for a third time
    delete @init_args{keys %{$HTML::FormFu::build_defaults}};
    my %args = map { $_ => $args->{$_} } grep { ! exists $init_args{$_} } keys %$args;
    $self->populate(\%args);

    return;
};

sub populate {
    my ( $self, $arg_ref ) = @_;

    # shallow clone the args so we don't stomp on them
    my %args = %$arg_ref;

    # we have to handle element_defaults seperately, as it is no longer a
    # simple hash key

    if ( exists $args{element_defaults} ) {
        $self->element_defaults( delete $args{element_defaults} );
    }

    # notes for @keys...
    # 'options', 'values', 'value_range' is for _Group elements,
    # to ensure any 'empty_first' value gets set first

    my @keys = qw(
        default_args
        auto_fieldset
        load_config_file
        element elements
        default_values
        filter              filters
        constraint          constraints
        inflator            inflators
        deflator            deflators
        query
        validator           validators
        transformer         transformers
        plugins
        options
        values
        value_range
    );

    my %defer;
    for (@keys) {
        $defer{$_} = delete $args{$_} if exists $args{$_};
    }

    eval {
        map { $self->$_( delete $args{$_} ) } keys %args;

        map      { $self->$_( $defer{$_} ) }
            grep { exists $defer{$_} } @keys;
    };
    croak $@ if $@;

    return $self;
}

1;
