package HTMLFormFu::RegressLocalization;
use base qw(Locale::Maketext);

sub localize {
    shift->maketext(@_);
}

1;
