package HTML::FormFu::Localize;

use strict;

use HTML::FormFu::Util qw( require_class );
use List::MoreUtils qw( any );
use List::MoreUtils qw( pairwise );
use Scalar::Util qw( blessed );
use Exporter qw( import );
use Carp qw( croak );

our @EXPORT = qw(
    localize
    add_localize_object
    get_localize_object_from_class
    get_localize_object_dies_on_missing_key
    add_default_localize_object
    get_localize_object
);

sub localize {
    my ( $self, @original_strings ) = @_;
    
    @original_strings = grep { defined } @original_strings;
    
    if ( !$self->{has_default_localize_object} ) {
        $self->add_default_localize_object;
    }
    
    my @localized_strings;

    foreach my $localize_data ( @{ $self->{localize_data} } ) {
        my $localize_object = $self->get_localize_object($localize_data);

        eval {
            @localized_strings = $localize_object->localize(@original_strings);
        };

        next if $@;

        # NOTE:
        # As FormFu uses L10N to return messages based on artificial message
        # ids (instead of english language as message ids) the assumption
        # that we just got a result from Locale::Maketext with AUTO = 1 seems
        # to be safe when localize returns the same string as handed over.
        if (   !$localize_data->{dies_on_missing_key}
            && scalar(@original_strings) == scalar(@localized_strings)
            && scalar( any { !$_ } pairwise { $a eq $b } @original_strings,
                @localized_strings ) == 0
            )
        {
            next;
        }

        last;
    }

    if ( !@localized_strings ) {
        @localized_strings = @original_strings;
    }

    return wantarray ? @localized_strings : $localized_strings[0];
}

sub add_localize_object {
    my ( $self, @objects ) = @_;

    croak 'no arguments given' if @_ < 2;

    foreach my $localize_object (@objects) {
        my $dies_on_missing_key = undef;

        if ( blessed $localize_object) {
            $dies_on_missing_key
                = $self->get_localize_object_dies_on_missing_key(
                $localize_object);
        }

        # add external localize object to the end of the list
        push @{ $self->{localize_data} },
            {
            localize_object     => $localize_object,
            dies_on_missing_key => $dies_on_missing_key,
            };
    }

    return $self;
}

sub get_localize_object_from_class {
    my ( $self, $class ) = @_;

    require_class($class);

    my $languages = $self->languages;
    $languages = [$languages] if ref $languages ne 'ARRAY';

    return $class->get_handle( @$languages );

}

sub get_localize_object_dies_on_missing_key {
    my ( $self, $localize_object ) = @_;

    # NOTE:
    # Findout how this class reacts on missing entries
    # this is an issue with catalyst and po-style localization
    #   (in pm-style localization, you could set
    #    $Hello::I18N::en::Lexicon{_AUTO} = 0;
    #    to avoid autocreating missing keys)

    # HINT:
    # Never use underscores for the beginning of the testkey as they
    # will lead Locale::Maketext to croak even if _AUTO is on (1) as
    # Locale::Maketext useses underscores to identify text for
    # processing via the AUTO-function (_compile).

    my $testkey = 'html_formfu_missing_key_test';
    
    eval { $localize_object->localize($testkey) };
    
    my $dies_on_missing_key = $@ ? 1 : 0;

    return $dies_on_missing_key;
}

sub add_default_localize_object {
    my ($self) = @_;

    my $localize_object
        = $self->get_localize_object_from_class( $self->localize_class );
    
    my $dies_on_missing_key = 1;

    # put FormFu localize object in first place
    unshift @{ $self->{localize_data} },
        {
        localize_object     => $localize_object,
        dies_on_missing_key => $dies_on_missing_key,
        };

    $self->{has_default_localize_object} = 1;

    return $self;
}

sub get_localize_object {
    my ( $self, $localize_data ) = @_;

    if ( !blessed $localize_data->{localize_object} ) {

        $localize_data->{localize_object}
            = $self->get_localize_object_from_class( $self->localize_class );

        $localize_data->{dies_on_missing_key}
            = $self->get_localize_object_dies_on_missing_key(
            $localize_data->{localize_object} );
    }

    return $localize_data->{localize_object};
}

1;
