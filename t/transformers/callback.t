use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $can_closure = sub {
    my ($value, $params) = @_;
    
    if ( $params->{foo} eq '1' ) {
        $value .= '_' . $params->{foo};
    }
    $value =~ s/\s*//g;
    
    return uc $value;
};

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->transformer('Callback')->callback( \&cb );
$form->element('Text')->name('bar')->transformer('Callback')
    ->callback("main::cb");
$form->element('Text')->name('coo')->transformer('Callback')
    ->callback( $can_closure );

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
            coo => 'sTrinG I waNT to CaNonize ',
        } );

    ok( $form->submitted_and_valid );

    is( $form->param('foo'), 1 );

    is_deeply( [ $form->param('bar') ], [ 0, 'A', 'b' ] );

    is( $form->param('coo'), 'STRINGIWANTTOCANONIZE_1' );
}
