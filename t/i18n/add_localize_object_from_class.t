use strict;
use warnings;
use Test::More tests => 2;
use HTML::FormFu;

use lib 't/lib';
use HTMLFormFu::RegressLocalization;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/i18n/add_localize_object_from_class.yml');

like( "$form", qr/\bThis field is required\b/, "properly localized" );

like( "$form", qr/\bFoo blah Baz\b/, "properly localized (added object took effect)" );
