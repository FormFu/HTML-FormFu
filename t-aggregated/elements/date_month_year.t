use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;
use DateTime;

my $dt = DateTime->new( month => 8, year => 2007 );

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Date')->name('foo')
    ->default($dt)
    ->field_order( [ qw/ month year / ])
    ->strftime('%m/%Y')
    ->month( {
        prefix      => '-- Month --',
        short_names => 1,
    } )
    ->year( {
        prefix => '-- Year --',
        list   => [ 2007 .. 2017 ],
    } )
    ->auto_inflate(1)
    ->constraint('Required');

$form->element('Date')->name('bar')
    ->default('08-2007')
    ->field_order( [ qw/ year month / ] )
    ->strftime('%m-%Y')
    ->year( { list => [ 2007 .. 2017 ] } );

$form->process;

is( "$form", <<HTML );
<form action="" method="post">
<div class="date">
<span class="elements">
<select name="foo_month">
<option value="">-- Month --</option>
<option value="1">Jan</option>
<option value="2">Feb</option>
<option value="3">Mar</option>
<option value="4">Apr</option>
<option value="5">May</option>
<option value="6">Jun</option>
<option value="7">Jul</option>
<option value="8" selected="selected">Aug</option>
<option value="9">Sep</option>
<option value="10">Oct</option>
<option value="11">Nov</option>
<option value="12">Dec</option>
</select>
<select name="foo_year">
<option value="">-- Year --</option>
<option value="2007" selected="selected">2007</option>
<option value="2008">2008</option>
<option value="2009">2009</option>
<option value="2010">2010</option>
<option value="2011">2011</option>
<option value="2012">2012</option>
<option value="2013">2013</option>
<option value="2014">2014</option>
<option value="2015">2015</option>
<option value="2016">2016</option>
<option value="2017">2017</option>
</select>
</span>
</div>
<div class="date">
<span class="elements">
<select name="bar_year">
<option value="2007" selected="selected">2007</option>
<option value="2008">2008</option>
<option value="2009">2009</option>
<option value="2010">2010</option>
<option value="2011">2011</option>
<option value="2012">2012</option>
<option value="2013">2013</option>
<option value="2014">2014</option>
<option value="2015">2015</option>
<option value="2016">2016</option>
<option value="2017">2017</option>
</select>
<select name="bar_month">
<option value="1">January</option>
<option value="2">February</option>
<option value="3">March</option>
<option value="4">April</option>
<option value="5">May</option>
<option value="6">June</option>
<option value="7">July</option>
<option value="8" selected="selected">August</option>
<option value="9">September</option>
<option value="10">October</option>
<option value="11">November</option>
<option value="12">December</option>
</select>
</span>
</div>
</form>
HTML

$form->process( {
        'foo_month', 6, 'foo_year', 2007,
        'bar_month', 7, 'bar_year', 2007,
    } );

ok( $form->submitted_and_valid );

my $foo = $form->param('foo');
my $bar = $form->param('bar');

isa_ok( $foo, 'DateTime' );
ok( !ref $bar );

is( $foo, "06/2007" );
is( $bar, "07-2007" );

is( "$form", <<HTML );
<form action="" method="post">
<div class="date">
<span class="elements">
<select name="foo_month">
<option value="">-- Month --</option>
<option value="1">Jan</option>
<option value="2">Feb</option>
<option value="3">Mar</option>
<option value="4">Apr</option>
<option value="5">May</option>
<option value="6" selected="selected">Jun</option>
<option value="7">Jul</option>
<option value="8">Aug</option>
<option value="9">Sep</option>
<option value="10">Oct</option>
<option value="11">Nov</option>
<option value="12">Dec</option>
</select>
<select name="foo_year">
<option value="">-- Year --</option>
<option value="2007" selected="selected">2007</option>
<option value="2008">2008</option>
<option value="2009">2009</option>
<option value="2010">2010</option>
<option value="2011">2011</option>
<option value="2012">2012</option>
<option value="2013">2013</option>
<option value="2014">2014</option>
<option value="2015">2015</option>
<option value="2016">2016</option>
<option value="2017">2017</option>
</select>
</span>
</div>
<div class="date">
<span class="elements">
<select name="bar_year">
<option value="2007" selected="selected">2007</option>
<option value="2008">2008</option>
<option value="2009">2009</option>
<option value="2010">2010</option>
<option value="2011">2011</option>
<option value="2012">2012</option>
<option value="2013">2013</option>
<option value="2014">2014</option>
<option value="2015">2015</option>
<option value="2016">2016</option>
<option value="2017">2017</option>
</select>
<select name="bar_month">
<option value="1">January</option>
<option value="2">February</option>
<option value="3">March</option>
<option value="4">April</option>
<option value="5">May</option>
<option value="6">June</option>
<option value="7" selected="selected">July</option>
<option value="8">August</option>
<option value="9">September</option>
<option value="10">October</option>
<option value="11">November</option>
<option value="12">December</option>
</select>
</span>
</div>
</form>
HTML

