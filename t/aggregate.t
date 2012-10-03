use strict;
use warnings;
use Test::More;

eval "require Test::Aggregate::Nested";
if ( $^O eq 'MSWin32' || $@ ) {
    plan skip_all => 'Test::Aggregate::Nested an non-Win32 OS required';
    exit;
}

my @classes = qw(
    bugs constraints deflators elements examples filters form i18n
    inflators internals model multiform multiform-misc multiform-nested-name
    multiform-no-combine multiform_hidden_name nested output_processors plugins
    repeatable templates transformers utils load_config);

Test::Aggregate::Nested->new( {
        dirs => [ map {"t/$_"} @classes ],

        # verbose => 1,
    } )->run;
