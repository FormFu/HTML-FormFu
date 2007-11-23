use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo')->constraint('Required');
$form->element('Text')->name('bar');
$form->element('Submit')->name('submit');

{
    my $xhtml = qq{<span class="submit">
<input name="submit" type="submit" />
</span>};

    is( $form->get_field( { type => 'Submit' } ), $xhtml );
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

    is( $form->get_field( { type => 'Submit' } ), $xhtml );
}
