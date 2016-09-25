use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/elements/url.yml');

my $expected_field_xhtml = qq{<div>
<input name="foo" type="url" title="Only http and https URLs allowed" />
</div>};

is( $form->get_field('foo'), $expected_field_xhtml );

# Valid
{
    $form->process( {
            foo => 'http://example.com',
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

# Invalid
{
    $form->process( {
            foo => 'ftp://example.com',
        } );

    ok( ! $form->valid('foo'), 'foo invalid' );
}
