use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->auto_fieldset( { nested_name => 'foo' } );

$form->element('Text')->name('bar')->validator('Callback')->callback(\&cb);

$form->element('Text')->name('baz');

# attached via form
$form->validator({
    type => 'Callback',
    name => 'foo.baz',
    callback => 'main::cb',
});

sub cb {
    my $value = shift;
    ok(1) if grep { $value eq $_ ? 1 : 0 } qw/ 1 0 a /;
    return 1;
}

# Valid
{
    $form->process( {
            'foo.bar' => 1,
            'foo.baz' => [ 0, 'a', 'b' ],
        } );

    ok( $form->valid('foo.bar') );
    ok( $form->valid('foo.baz') );
    
    is( $form->param('foo.bar'), 1 );
    
    is_deeply(
        [ $form->param('foo.baz') ],
        [ 0, 'a', 'b' ]
    );
}
