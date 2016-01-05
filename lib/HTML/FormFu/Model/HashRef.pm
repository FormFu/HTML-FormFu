package HTML::FormFu::Model::HashRef;

use Moose;
use MooseX::Attribute::FormFuChained;

extends 'HTML::FormFu::Model';

use Hash::Flatten;
use Scalar::Util qw(blessed);

has flatten => ( is => 'rw' );
has options => ( is => 'rw' );

has _repeatable => ( is => 'rw', traits => ['FormFuChained'] );
has _multi      => ( is => 'rw', traits => ['FormFuChained'] );

has deflators => (
    is      => 'rw',
    default => 1,
    lazy    => 1,
    traits  => ['FormFuChained'],
);

has inflators => (
    is      => 'rw',
    default => 1,
    lazy    => 1,
    traits  => ['FormFuChained'],
);

sub default_values {
    my ( $self, $data ) = @_;
    map { $_->default(undef) }
        ( grep { $_->is_field } @{ $self->form->get_all_elements } );
    $self->_default_values( $self->form, $data );
    return $self;
}

sub _default_values {
    my ( $self, $form, $data ) = @_;
    my $elements = $form->get_elements;
    foreach my $element ( @{$elements} ) {
        my $name        = $element->name        || "";
        my $nested_name = $element->nested_name || "";
        $name =~ s/_\d+$// if ($name);
        if ( $element->is_repeatable ) {
            my $value = $data->{$name} || $data->{$nested_name};
            unless ($value) {
                $element->repeat(0);
                map { $element->remove_element($_) }
                    @{ $element->get_elements };
                next;
            }
            my $k = scalar @{$value};
            $element->repeat($k);
            my $childs = $element->get_elements;
            for ( my $i = 0; $i < $k; $i++ ) {
                $self->_default_values( $childs->[$i], $value->[$i] );
            }
        }
        elsif ( $element->is_block && $element->is_field )
        {    # is a Multi element
            ref $data->{$name} eq "HASH"
                ? $self->_default_values( $element, $data->{$name} )
                : $element->default( $data->{$name} );
        }
        elsif ( $element->is_block ) {
            $self->_default_values( $element,
                  $nested_name
                ? $data->{$nested_name}
                : $data );
        }
        else {
            if ( $self->inflators && @{ $element->get_inflators } > 0 ) {
                my @inflators = @{ $element->get_inflators };
                map { $element->default( $_->process( $data->{$name} ) ) }
                    @inflators;
            }
            else {

                $element->default( $data->{$name} );
            }
        }

    }

    return $self;

}

sub update { shift->create(@_) }

sub create {
    my $self = shift;
    if ( $self->form->submitted ) {
        my $input = _escape_hash( $self->form->input );
        my $hf    = Hash::Flatten->new(
            { ArrayDelimiter => '_', HashDelimiter => '.' } );
        $input = _unescape_hash( $hf->unflatten( $self->form->input ) );
        $self->default_values(
            $self->_unfold_repeatable( $self->form, $input ) );
    }
    $self->form->render_data;
    my $obj = $self->_as_object_get( $self->form );
    if ( $self->flatten ) {
        my $hf = Hash::Flatten->new(
            { ArrayDelimiter => '_', HashDelimiter => '.' } );
        $obj = $self->_unfold_repeatable( $self->form, $hf->flatten($obj) );
    }
    return $obj;
}

sub _as_object_get {
    my $self  = shift;
    my $form  = shift;
    my $e     = $form->get_all_elements;
    my $names = {};
    foreach my $element ( @{$e} ) {
        my $name = $element->nested_name;
        next unless $name;
        next if ( $element->type eq "Multi" );
        my $es_name = _escape_name($name);
        if (   $self->options
            && $element->can('_options')
            && @{ $element->_options } > 0 )
        {
            my @options = @{ $element->_options };
            my @values
                = ref $element->default eq "ARRAY"
                ? @{ $element->default }
                : $element->default;
            $names->{$es_name} = [];
            foreach my $value (@values) {
                my @option
                    = grep { defined $value && $_->{value} eq $value } @options;
                unless (@option) {
                    @options = map { @{ $_->{group} || [] } } @options;
                    @option = grep { $_->{value} eq $value } @options;
                }
                my $obj
                    = [ map { { value => $_->{value}, label => $_->{label} } }
                        @option ];

                push( @{ $names->{$es_name} }, $obj->[0] ) if $name;
            }
            $names->{$es_name} = $names->{$es_name}->[0] if scalar @values == 1;
            $names->{$es_name} ||= { value => undef, label => undef };
        }
        elsif ( $element->is_field && $self->deflators ) {
            my $deflators = $element->get_deflators;
            $names->{$es_name} = $element->default
                if ( $element->can('default') );
            map { $names->{$es_name} = $_->deflator( $names->{$es_name} ) }
                @{$deflators};
        }
        else {
            $names->{$es_name} = $element->default
                if ( $element->can('default') );
        }

        if ( blessed $names->{$es_name} ) { delete $names->{$es_name} }
    }

    my $hf = Hash::Flatten->new( { ArrayDelimiter => '_' } );

    return $self->_unfold_repeatable( $form,
        $self->flatten ? $names : $hf->unflatten($names) );
}

sub _escape_hash {
    my $hash = shift;
    my $method = shift || \&_escape_name;
    return $hash unless ( ref $hash );
    foreach my $k ( keys %$hash ) {
        my $v = delete $hash->{$k};
        if ( ref $v eq 'HASH' ) {
            $hash->{ $method->($k) } = _escape_hash( $v, $method );
        }
        elsif ( ref $v eq 'ARRAY' ) {
            $hash->{ $method->($k) }
                = [ map { _escape_hash( $_, $method ) } @$v ];
        }
        else {
            $hash->{ $method->($k) } = $v;
        }
    }
    return $hash;
}

sub _unescape_hash {
    return _escape_hash( shift, \&_unescape_name );
}

sub _escape_name {
    my $name = shift;
    $name =~ s/_/\\_/g;
    $name =~ s/\\(_\d+(\.|$))/$1/g;
    return $name;
}

sub _unescape_name {
    my $name = shift;
    $name =~ s/\\_/_/g;
    $name =~ s/\\\./\./g;
    return $name;
}

sub _unfold_repeatable {
    my $self = shift;
    my $form = shift;
    my $data = shift;
    return $data unless ( ref $data eq "HASH" );
    my $new = {};

    while ( my ( $k, $v ) = each %{$data} ) {
        my $key = _unescape_name($k);

        if ( $self->get_repeatable($key) ) {
            $new->{$key} = [];

            # iterate over all array elements
            # we ignore the first one (index 0) as it is undef as we start
            # counting the repeated element names with 1 and the automatic
            # from Hash::Flatten assumed 0 as first index while unflattening
            # the parameter names
            # Example:
            # $v    = [
            #           undef,
            #           {
            #             'foo' => 'bar',
            #             'id' => 1
            #           },
            #           {
            #             'foo' => 'baz',
            #             'id' => 2
            #           }
            #         ];
            for ( my $i = 1; $i < @{ $v || [] }; $i++ ) {

                # process all key value pairs in an array element
                while ( my ( $name, $values ) = each %{ $v->[$i] } ) {

            # add an empty hash to array of unfolded data if not already present
                    push( @{ $new->{$key} }, {} )
                        unless $new->{$key}->[ $i - 1 ];

                    # store processed values
                    $new->{$key}->[ $i - 1 ]->{$name}
                        = $self->_unfold_repeatable( $form, $values );
                }
            }
        }
        elsif ( $self->get_multi($key) && ref $v eq "ARRAY" ) {
            for ( @{ $v || [] } ) {
                $new->{$key} = $_;
                last if $new->{$key};
            }
        }
        else {
            $new->{$key} = $self->_unfold_repeatable( $form, $v );
        }
    }

    return $new;
}

sub get_multi {
    my $self    = shift;
    my $element = shift;
    unless ( $self->_multi ) {
        my %multis = ();
        my $multis = $self->form->get_all_elements( { type => qr/Multi/ } );
        foreach my $multi ( @{ $multis || [] } ) {
            my @multis;
            map { push( @multis, $_->name ) } @{ $multi->get_elements };
            map { s/_\d+//; $multis{$_} = 1 } @multis;
        }
        $self->_multi( \%multis );
    }
    return $self->_multi->{$element};

}

sub get_repeatable {
    my $self    = shift;
    my $element = shift;
    unless ( $self->_repeatable ) {
        my %rep = ();
        my $rep = $self->form->get_all_elements( { type => qr/Repeatable/ } );

        # TODO - Mario Minati 19.05.2009
        # use $_->delimiter to split the keys
        foreach my $rep_element ( @{ $rep || [] } ) {
            my $name = $rep_element->nested_name;
            die
                "A Repeatable element without a nested_name attribute cannot be handled by Model::HashRef"
                unless $name;
            $name =~ s/_\d+//;
            $rep{$name} = 1;
        }
        $self->_repeatable( \%rep );
    }
    return $self->_repeatable->{$element};

}

__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

HTML::FormFu::Model::HashRef - handle hashrefs

=head1 SYNOPSIS

  ---
    elements:
      - user_id
      - user_name
      - type: Repeatable
        nested_name: addresses
        elements:
          - type: Hidden
            name: id
          - street


  $form->model('HashRef')->default_values( {
    user_id => 123,
    user_name => 'Hans',
    addresses => [
      { id => 2,
        street => 'Somewhere' },
      { id => 3,
        street => 'Somewhere Else' }
    ]    
    } );
  
  $form->default_model('HashRef');
  my $hashref = $form->model->create();
  
  # $hashref is very much the same as the hashref you passed to default_values()

=head1 DESCRIPTION

If you need the content of a formular as hashref or for processing with other modules 
like C<JSON> you can use this model.

=head1 METHODS

=head2 create

This method creates a hashref from a filled form. This form can be filled by calling
L<HTML::FormFu/default_values>, default_values of any other model class (e. g. L<HTML::FormFu::Model::DBIC>)
or by simply submitting the form.

If L</deflators> is true all deflators are processed (defaults to C<1>).

If L</options> is true the value of all elements which have options like 
L<HTML::FormFu::Element::Select> will be transformed.

  ---
    elements:
      - type: Select
        name: select
        options:
          - [1, "Foo"]
          - [2, "Bar"]

If the value of C<select> is C<1>, L<create> will create this hashref:

  { 'select' => { label => 'Foo', value => 1 } }

If there is more than one value selected, an arrayref is created instead:

  { 'select' => [ { label => 'Foo', value => 1 },
                  { label => 'Bar', value => 2 } ] }

If L</options> is false, the output will look like this:

  { 'select' => 1 }

respectively

  { 'select' => [1, 2] }

L</options> is false by default.

To get a flattened hash, you can set C</flatten> to a true value (defaults to C<0>).
This will generate a hash which uses the nested name of each field as key and the value
of this field as hash value. If there is a field which has more than one value,
a counter is added. The above example would result in a hash like this using C</flatten>:

  { 'select_0' => 1,
    'select_1' => 2 }


=head2 update

Alias for L</create>.

=head2 default_values

Populate a form using a hashref. This hashref has the same format as the output of L</create>.
If L</inflators> is true, all inflators will be processed (defaults to C<1>).

=head1 CONFIGURATION

These methods do not return the model object so chaining is not possible!

=head2 options

Adds the label of a value to the hashref if the element has L<HTML::FormFu::Role::Element::Group/options>.
See L</create> for an example. Defaults to C<0>.

=head2 flatten

Flattens the hash using L<Hash::Flatten>. See L</create> for an example. Defaults to C<0>.

=head2 deflators

If true, processes deflators in C</create>. Defaults to C<1>.

=head2 inflators

If true, processes inflators in C</default_values>. Defaults to C<1>.

=head1 SEE ALSO

L<HTML::FormFu>, L<Hash::Flatten>

=head1 AUTHOR

Moritz Onken, C<< onken@houseofdesign.de >>
