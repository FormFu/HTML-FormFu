use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

# dies

eval {
    $form->element('Radiogroup')->name('foo')->options( [ {
                label   => 'fu',
                value   => '1',
                unknown => 'dies',
            } ] );
};

ok($@);
