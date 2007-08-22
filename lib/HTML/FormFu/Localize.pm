package HTML::FormFu::Localize;

use warnings;
use strict;

use HTML::FormFu::Util qw/ require_class /;
use List::MoreUtils qw/ pairwise /;
use Scalar::Util qw( blessed );
use Exporter qw/ import /;
use Carp qw/ croak /;

our @EXPORT = qw/
    localize
    add_localize_object
    get_localize_object_from_class
    get_localize_object_dies_on_missing_key
    add_default_localize_object
    get_localize_object
    /;

sub localize {
    my $self              = shift;
    my @localized_strings = ();

    $self->add_default_localize_object
        if !$self->{has_default_localize_object};

    #warn "* looking for ". join ',', @_;

    foreach my $localize_data ( @{ $self->{localize_data} } ) {
        my $localize_object = $self->get_localize_object($localize_data);

        #warn "  processing ". ref $localize_object;

        eval { @localized_strings = $localize_object->localize(@_); };

        #warn "  no match" if $@;

        next if $@;

        # NOTE:
        # As FormFu uses L10N to return messages based on artificial message
        # ids (instead of english language as message ids) the assumption
        # that we just got a result from Locale::Maketext with AUTO = 1 seams
        # to be save when localize returns the same string as handed over.
        if (   !$localize_data->{dies_on_missing_key}
            && scalar(@_) == scalar(@localized_strings)
            && scalar( grep { !$_ } pairwise { $a eq $b } @_,
                @localized_strings ) == 0 )
        {

            #warn "  invalid match";
            next;
        }

        #warn "  match found";
        last;
    }

    @localized_strings = @_ if ( not scalar @localized_strings );

    return wantarray ? @localized_strings : $localized_strings[0];
}

sub add_localize_object {
    my $self = shift;

    croak 'no arguments given' if @_ < 1;

    foreach my $localize_object (@_) {
        my $dies_on_missing_key = undef;

        if ( blessed $localize_object) {
            $dies_on_missing_key
                = $self->get_localize_object_dies_on_missing_key(
                $localize_object);
        }

    #warn "> add_localize_object ".((ref $localize_object) || $localize_object);
        unshift @{ $self->{localize_data} },
            {
            localize_object     => $localize_object,
            dies_on_missing_key => $dies_on_missing_key,
            };
    }

    return $self;
}

sub get_localize_object_from_class {
    my $self = shift;
    my ($class) = @_;

    require_class($class);

    return $class->get_handle( @{ $self->languages } );

}

sub get_localize_object_dies_on_missing_key {
    my $self = shift;
    my ($localize_object) = @_;

    # NOTE:
    # Findout how this class reacts on missing entries
    # this is an issue with catalyst and po-style localization
    #   (in pm-style localization, you could set
    #    $Hello::I18N::en::Lexicon{_AUTO} = 0;
    #    to avoid autocreating missing keys)

    # HINT:
    # Never use underscores for te beginning of the testkey as they
    # will lead Locale::Maketext to croak even if _AUTO is on (1) as
    # Locale::Maketext useses underscores to identify text for
    # processing via the AUTO-function (_compile).

    my $testkey = 'html_formfu_missing_key_test';
    my $dies_on_missing_key
        = ( eval { $localize_object->localize($testkey); } ? 0 : 1 );

    return $dies_on_missing_key;
}

sub add_default_localize_object {
    my $self = shift;

    my $localize_object
        = $self->get_localize_object_from_class( $self->localize_class );
    my $dies_on_missing_key = 1;

    push @{ $self->{localize_data} },
        {
        localize_object     => $localize_object,
        dies_on_missing_key => $dies_on_missing_key,
        };

    $self->{has_default_localize_object} = 1;

    return $self;
}

sub get_localize_object {
    my $self = shift;
    my ($localize_data) = @_;

    if ( !blessed $localize_data->{localize_object} ) {

        #warn "+ loading ".$localize_data->{localize_object};

        $localize_data->{localize_object}
            = $self->get_localize_object_from_class( $self->localize_class );

        $localize_data->{dies_on_missing_key}
            = $self->get_localize_object_dies_on_missing_key(
            $localize_data->{localize_object} );
    }

    return $localize_data->{localize_object};
}

1;
