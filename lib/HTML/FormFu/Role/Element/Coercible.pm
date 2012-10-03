package HTML::FormFu::Role::Element::Coercible;
use Moose::Role;

use Carp qw( croak );
use HTML::FormFu::Util qw( require_class );

sub _coerce {
    my ( $self, %args ) = @_;

    for (qw( type attributes package )) {
        croak "$_ argument required" if !defined $args{$_};
    }

    my $class = $args{type};
    if ( $class !~ /^\+/ ) {
        $class = "HTML::FormFu::Element::$class";
    }

    require_class($class);

    my $element = $class->new( { type => $args{type}, } );

    for my $method ( qw(
        name
        attributes              comment
        comment_attributes      label
        label_attributes        label_filename
        render_method           parent
        ) )
    {
        $element->$method( $self->$method );
    }

    _coerce_processors_and_errors( $self, $element, %args );

    $element->attributes( $args{attributes} );

    croak "element cannot be coerced to type '$args{type}'"
        unless $element->isa( $args{package} )
            || $element->does( $args{package} );

    $element->value( $self->value );

    return $element;
}

sub _coerce_processors_and_errors {
    my ( $self, $element, %args ) = @_;

    if ( $args{errors} && @{ $args{errors} } > 0 ) {

        my @errors = @{ $args{errors} };
        my @new_errors;

        for my $list ( qw(
            _filters        _constraints
            _inflators      _validators
            _transformers   _deflators
            ) )
        {
            $element->$list( [] );

            for my $processor ( @{ $self->$list } ) {
                my @errors_to_copy = map { $_->clone }
                    grep { $_->processor == $processor } @errors;

                my $processor_clone = $processor->clone;

                $processor_clone->parent($element);

                map { $_->processor($processor_clone) } @errors_to_copy;

                push @{ $element->$list }, $processor_clone;

                push @new_errors, @errors_to_copy;
            }
        }
        $element->_errors( \@new_errors );
    }
    else {
        $element->_errors( [] );
    }

    return;
}

1;
