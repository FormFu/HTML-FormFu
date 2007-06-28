package HTML::FormFu::Element::group;

use strict;
use warnings;
use base 'HTML::FormFu::Element::field';

use HTML::FormFu::ObjectUtil qw/ _coerce /;
use HTML::FormFu::Util qw/ append_xml_attribute /;
use Storable qw( dclone );
use Carp qw( croak );

__PACKAGE__->mk_accessors(qw/ _options /);

sub new {
    my $self = shift->SUPER::new(@_);

    $self->_options( [] );
    $self->container_attributes( {} );

    return $self;
}

sub options {
    my ( $self, $arg ) = @_;
    my ( @options, @new );

    croak "options argument must be a single array-ref" if @_ > 2;

    if ( defined $arg ) {
        eval { @options = @$arg };
        croak "options argument must be an array-ref" if $@;

        for my $item (@options) {
            push @new, $self->_parse_option($item);
        }
    }

    $self->_options( \@new );

    return $self;
}

sub _parse_option {
    my ( $self, $item ) = @_;

    eval { my %x = %$item };
    if ( !$@ ) {
        if ( exists $item->{group} ) {
            my @group = @{ $item->{group} };
            my @new;
            for my $groupitem (@group) {
                push @new, $self->_parse_option($groupitem);
            }
            my %group = ( group => \@new );
            $group{label} = $item->{label};
            $group{attributes} = $item->{attributes} || {};

            return \%group;
        }
        $item->{attributes}       = {} if !exists $item->{attributes};
        $item->{label_attributes} = {} if !exists $item->{label_attributes};
        return $item;
    }

    eval { my @x = @$item };
    if ( !$@ ) {
        return {
            value            => $item->[0],
            label            => $item->[1],
            attributes       => {},
            label_attributes => {},
        };
    }

    croak "each options argument must be a hash-ref or array-ref";
}

sub values {
    my ( $self, $arg ) = @_;
    my ( @values, @new );

    croak "values argument must be a single array-ref of values" if @_ > 2;

    if ( defined $arg ) {
        eval { @values = @$arg };
        croak "values argument must be an array-ref" if $@;
    }

    @new = (
        map { { value            => $_,
                label            => ucfirst $_,
                attributes       => {},
                label_attributes => {},
            }
            } @values
    );

    $self->_options( \@new );

    return $self;
}

sub value_range {
    my ( $self, $arg ) = @_;
    my ( @values );

    croak "value_range argument must be a single array-ref of values" if @_ > 2;

    if ( defined $arg ) {
        eval { @values = @$arg };
        croak "value_range argument must be an array-ref" if $@;
    }
    
    croak "range must contain at least 2 values" if @$arg < 2;
    
    my $end   = pop @values;
    my $start = pop @values;

    return $self->values([ @values, $start .. $end ]);
}

sub prepare_attrs {
    my ( $self, $render ) = @_;

    my $submitted = $self->form->submitted;
    my $default   = $self->default;
    my $value     = $self->form->input->{ $self->name };
    
    for my $option ( @{ $render->{options} } ) {
        if ( exists $option->{group} ) {
            for my $item ( @{ $option->{group} } ) {
                $self->_prepare_attrs( $submitted, $value, $default, $item );
            }
        }
        else {
            $self->_prepare_attrs( $submitted, $value, $default, $option );
        }
    }
    
    $self->SUPER::prepare_attrs($render);

    return;
}

sub render {
    my $self = shift;

    my $render = $self->SUPER::render({
        options           => dclone( $self->_options ),
        @_ ? %{$_[0]} : ()
        });

    return $render;
}

sub as {
    my ( $self, $type, %attrs ) = @_;

    return $self->_coerce(
        type       => $type,
        attributes => \%attrs,
        errors     => $self->_errors,
        package    => __PACKAGE__,
    );
}

sub clone {
    my $self = shift;
    
    my $clone = $self->SUPER::clone(@_);
    
    $clone->_options( dclone $self->_options );
    
    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::group - grouped form field base-class

=head1 DESCRIPTION

Base class for L<HTML::FormFu::Element::RadioGroup> and 
L<HTML::FormFu::Element::Select> fields.

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element::field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
