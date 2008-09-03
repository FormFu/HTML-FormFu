use strict;
use warnings;
use lib 'lib';
use HTML::FormFu;

for ( 1..100 ) {
    my $form = HTML::FormFu->new;
    
    $form->load_config_file('benchmarks/formfu.yml');
    
    $form->process({
        hidden1     => 42,
        text1       => 'aaa',
        text2       => 101,
        text3       => 'foo',
        text4       => 'bar',
        password1   => 'toomanysecrets',
        file1       => 'file.txt',
        textarea1   => 'aaa',
        textarea2   => 'bbb',
        select1     => 'one',
        select2     => '2',
        radio4      => 'x',
        checkbox1   => 'y',
        radiogroup1 => 'one',
        radiogroup2 => 'two',
        radiogroup3 => '3',
        radiogroup4 => 'one',
        radio1      => 1,
        radio2      => 2,
        select3     => '',
        select4     => 'one',
        select5     => 'two',
        checkbox2   => 'on',
        text5       => 'zzz',
        textarea3   => "foo\nbar",
        submit      => 'Submit Value',
    });
    
    $form->submitted_and_valid
        or do { eval "use Data::Dumper"; die Dumper( $form->has_errors ) };
    
    my $output = "$form";
}

