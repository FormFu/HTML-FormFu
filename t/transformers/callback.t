use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo')->transformer('Callback')->callback(\&cb);
$form->element('Text')->name('bar')->transformer('Callback')->callback("main::cb");

sub cb {
    my $value = shift;
    
    $value =~ s/a/A/;
    
    return $value;
}

# Valid
{
    $form->process( {
            foo => 1,
            bar => [ 0, 'a', 'b' ],
        } );

    ok( $form->submitted_and_valid );

    is ( $form->param('foo'), 1 );

    is_deeply(
        [ $form->param('bar') ],
        [ 0, 'A', 'b' ]
    );
}
