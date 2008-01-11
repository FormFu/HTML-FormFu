use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $foo = $form->element('Select')->name('foo')->value_range( [ 2000, 2010 ] );

my $bar = $form->element('Select')->name('bar')
    ->value_range( [ 'year', 2000, 2002 ] );

my $foo_xhtml = qq{<span class="select">
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

is( "$foo", $foo_xhtml );

my $bar_xhtml = qq{<span class="select">
<select name="bar">
<option value="year">Year</option>
<option value="2000">2000</option>
<option value="2001">2001</option>
<option value="2002">2002</option>
</select>
</span>};

is( "$bar", $bar_xhtml );
