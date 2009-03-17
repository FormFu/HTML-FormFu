use strict;
use warnings;

use Test::More tests => 4;
use HTML::FormFu;
use Path::Class::File;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->elements([
    { type => "Text", name => "test1", deflator => { type => "PathClassFile"} },
    { type => "Text", name => "test2", deflator => { type => "PathClassFile", relative => 't'} },
    { type => "Text", name => "test3", deflator => { type => "PathClassFile", absolute => 1} },
    { type => "Text", name => "test4", deflator => { type => "PathClassFile", basename => 1} },

  
    
    ]);

$form->process;

my $file = Path::Class::File->new('t/deflators/pathclassfile.t');

for (1..4) {
    $form->get_field('test'.$_)->default($file);
}

my $value = "\Q".$file->relative."\E";
like($form->get_field('test1'), qr{value="$value"});
$value = "\Q".$file->relative('t')."\E";
like($form->get_field('test2'), qr{value="$value"});
$value = "\Q".$file->absolute."\E";
like($form->get_field('test3'), qr{value="$value"});
$value = "\Q".$file->basename."\E";
like($form->get_field('test4'), qr{value="$value"});
