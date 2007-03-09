use strict;
use warnings;

use Test::More tests => 10;

use HTML::FormFu;

my $form = HTML::FormFu->new;

ok( $form->element('text')->name('foo') );
ok( my $blank = $form->element('blank')->name('bar') );

is( $form->get_field('bar'), "" );

is( $form->get_field('bar')->render->label_tag, "" );
is( $form->get_field('bar')->render->field_tag, "" );

my $form_xhtml = <<EOF;
<form action="" method="post">
<span class="text">
<input name="foo" type="text" />
</span>

</form>
EOF

is( $form, $form_xhtml );

{
    $form->process( {
            foo => 'yada',
            bar => '23',
        } );

    ok( $form->valid('foo') );
    ok( $form->valid('bar') );

    is( $form->params->{foo}, 'yada' );
    is( $form->params->{bar}, 23 );
}
