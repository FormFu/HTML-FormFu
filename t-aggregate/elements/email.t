use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

ok( my $element = $form->element('Email')->name('foo') );

my $expected_field_xhtml = qq{<div>
<input name="foo" type="email" />
</div>};

is( "$element", $expected_field_xhtml );

# Valid
{
    $form->process( {
            foo => 'test@example.com',
        } );

    ok( $form->valid('foo'), 'foo valid' );
}

# Invalid
{
    $form->process( {
            foo => 'example.com',
        } );

    ok( ! $form->valid('foo'), 'foo invalid' );
}
