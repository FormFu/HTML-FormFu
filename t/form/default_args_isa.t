use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;
use Storable qw( dclone );

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/form/default_args_isa.yml');

is( $form->get_element( { type => 'Fieldset' } )->attrs->{class},
    'does_block' );

# Multi gets default_args for Block, Field, Multi
my $multi = $form->get_all_element( { type => 'Multi' } );
is( $multi->attrs->{class}, 'does_block' );
is( $multi->comment,        'Does Field' );
is( $multi->label,          'My Multi' );

# Text gets default_args for Field, Input
my $text = $form->get_field( { name => 'bar' } );
is( $text->comment, 'Does Field' );
is( $text->id,      'bar' );

is( "$form", <<HTML );
<form action="" method="post">
<fieldset class="does_block">
<div>
<label>My Multi</label>
<span class="does_block elements">
<input name="foo.bar" type="text" id="bar" />
</span>
<span>
Does Field
</span>
</div>
</fieldset>
</form>
HTML
