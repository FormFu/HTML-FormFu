use strict;
use warnings;
use lib 'lib';
use HTML::FormFu;
use Template;

my $form = HTML::FormFu->new;

$form->load_config_file('examples/vertically-aligned/vertically-aligned.yml');

my $tt = Template->new;

$tt->process(
    'examples/vertically-aligned/vertically-aligned.tt',
    { form => $form },
    'examples/vertically-aligned/vertically-aligned.html',
) || die $tt->error;
