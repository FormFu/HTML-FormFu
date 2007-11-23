use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->auto_fieldset( { nested_name => 'foo' } );

$form->element('Text')->name('bar')->transformer('Callback')->callback(\&cb);
$form->element('Text')->name('baz')->transformer('Callback')->callback("main::cb");

sub cb {
    my $value = shift;
    
    $value =~ s/a/A/;
    
    return $value;
}

# Valid
{
    $form->process( {
            "foo.bar" => 1,
            "foo.baz" => [ 0, 'a', 'b' ],
        } );

    ok( $form->submitted_and_valid );

    is ( $form->param('foo.bar'), 1 );

    is_deeply(
        [ $form->param('foo.baz') ],
        [ 0, 'A', 'b' ]
    );
}
