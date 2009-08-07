use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/elements/recaptcha_constraint_args.yml');

is(
   $form->get_constraint( type => 'reCAPTCHA' )->message,
   'wrong!',
);
