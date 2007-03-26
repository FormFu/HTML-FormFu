use strict;
use warnings;
use Encode;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')
     ->name('foo')
     ->filter('Encode')
     ->candidates( qw(euc-jp sjis jis) )
     ->encode_to( 'euc-jp' );

my $utf8_foo     = decode_utf8('エイチティーエムエル::フォームフー');
my $original_foo = encode('sjis', $utf8_foo);
my $filtered_foo = encode('euc-jp', $utf8_foo);

$form->process( { foo => $original_foo, } );

# foo is filtered
is( decode('euc-jp', $form->param('foo')), $utf8_foo, 'foo filtered' );
is( decode('euc-jp', $form->params->{foo}), $utf8_foo, 'foo filtered' );
