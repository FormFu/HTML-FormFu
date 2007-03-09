use strict;
use warnings;
use HTML::FormFu;
use Template;

my $form = HTML::FormFu->new->load_config_file('examples/vertically-aligned.yml');

my $tt = Template->new;

$tt->process(
    'examples/vertically-aligned.tt',
    { form => $form },
    'examples/vertically-aligned.html',
) || die $tt->error;
