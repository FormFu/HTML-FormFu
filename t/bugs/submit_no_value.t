use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')->constraint('Required');
$form->element('text')->name('bar');
$form->element('submit')->name('submit');

{
    my $xhtml = qq{<span class="submit">
<input name="submit" type="submit" />
</span>};

    is( $form->get_field( { type => 'submit' } ), $xhtml );
}

=pod

After an error, check that submit doesn't contain C<< value="" >>, 
because the browser won't display the default text label,
"submit Query" or whatever.

=cut

{
    $form->process( { bar => 1 } );

    my $xhtml = qq{<span class="submit">
<input name="submit" type="submit" />
</span>};

    is( $form->get_field( { type => 'submit' } ), $xhtml );
}
