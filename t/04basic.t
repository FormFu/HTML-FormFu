use strict;
use warnings;
use YAML::Syck qw( LoadFile );

use Test::More tests => 7;

use HTML::FormFu;

my $form = HTML::FormFu->new( { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->action('/foo/bar')->id('form')->auto_id('%n');

my $fs = $form->element('Fieldset')->legend('Jimi');

$fs->element('Text')->name('age')->label('Age')->comment('x')
    ->constraints( [ 'Integer', 'Required', ] );

$fs->element('Text')->name('name')->label('Name');
$fs->element('Hidden')->name('ok')->value('OK');

$form->constraints( {
        type => 'Required',
        name => 'name',
    } );

$form->filter('HTMLEscape');

# hash-ref

my $alt_hash = {
    action   => '/foo/bar',
    id       => 'form',
    auto_id  => '%n',
    elements => [ {
            type     => 'Fieldset',
            legend   => 'Jimi',
            elements => [ {
                    type        => 'Text',
                    name        => 'age',
                    label       => 'Age',
                    comment     => 'x',
                    constraints => [ 'Integer', 'Required', ],
                },
                { type => 'Text',   name => 'name', label => 'Name', },
                { type => 'Hidden', name => 'ok',   value => 'OK', },
            ],
        }
    ],
    constraints => {
        type => 'Required',
        name => 'name',
    },
    filters => ['HTMLEscape'],
};

# hash-ref from yaml

my $yml_hash = LoadFile('t/04basic.yml');

# compare hash-refs

is_deeply( $yml_hash, $alt_hash );

# xhtml output

my $alt_form = HTML::FormFu->new($alt_hash);
$alt_form->tt_args( { INCLUDE_PATH => 'share/templates/tt/xhtml' } );

my $yml_form = HTML::FormFu->new( { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );
$yml_form->load_config_file('t/04basic.yml');

my $xhtml = <<EOF;
<form action="/foo/bar" id="form" method="post">
<fieldset>
<legend>Jimi</legend>
<span class="text comment label">
<label for="age">Age</label>
<input name="age" type="text" id="age" />
<span class="comment">
x
</span>
</span>
<span class="text label">
<label for="name">Name</label>
<input name="name" type="text" id="name" />
</span>
<input name="ok" type="hidden" value="OK" id="ok" />
</fieldset>
</form>
EOF

is( "$form",     $xhtml );
is( "$alt_form", $xhtml );
is( "$yml_form", $xhtml );

# With mocked basic query
{
    $form->process( {
            age  => 'a',
            name => 'sri',
        } );

    ok( $form->valid('name'), 'name is valid' );
    ok( !$form->valid('age'), 'age is not valid' );

    my $errors = $form->get_errors;

    is( @$errors, 1 );
}
