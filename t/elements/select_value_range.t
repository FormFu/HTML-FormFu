use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $field = $form->element('select')->name('foo')
        ->value_range([ 2000, 2010 ]);

my $field_xhtml = qq{<span class="select">
<select name="foo">
<option value="2000">2000</option>
<option value="2001">2001</option>
<option value="2002">2002</option>
<option value="2003">2003</option>
<option value="2004">2004</option>
<option value="2005">2005</option>
<option value="2006">2006</option>
<option value="2007">2007</option>
<option value="2008">2008</option>
<option value="2009">2009</option>
<option value="2010">2010</option>
</select>
</span>};

is( "$field", $field_xhtml, 'stringified field' );
