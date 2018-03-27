use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->action('/foo/bar')->id('form');

my $fs = $form->element('Fieldset')->legend('Jimi');

$fs->element('Text')->name('age')->label('Age')->comment('x')->constraints( [
        {   type    => 'Integer',
            message => 'No integer.',
        },
        {   type    => 'Integer',
            message => 'This too!',
        },
    ] );

$fs->element('Text')->name('name')->label('Name');
$fs->element('Hidden')->name('ok')->value('OK');

$fs->constraint(
    {   type    => 'Required',
        names   => [qw/ age name /],
        message => 'Missing value.',
    } );

$fs->filter('HTMLEscape');

# load_config_file

my $alt_form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$alt_form->load_config_filestem('t/load_config/load_config_file_form');

is_deeply( $alt_form, $form );

# xhtml output

my $xhtml = <<EOF;
<form action="/foo/bar" id="form" method="post">
<fieldset>
<legend>Jimi</legend>
<div>
<label>Age</label>
<input name="age" type="text" />
<span>
x
</span>
</div>
<div>
<label>Name</label>
<input name="name" type="text" />
</div>
<input name="ok" type="hidden" value="OK" />
</fieldset>
</form>
EOF

is( "$form", $xhtml );
