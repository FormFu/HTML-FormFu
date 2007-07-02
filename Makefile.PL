use inc::Module::Install;

name 'HTML-FormFu';
all_from 'lib/HTML/FormFu.pm';

requires 'perl' => '5.8.1';
requires 'Carp';
requires 'Class::Accessor::Chained::Fast';
requires 'Class::Data::Accessor';
requires 'Config::Any';
requires 'Date::Calc';
requires 'DateTime::Format::Builder';
requires 'Email::Valid';
requires 'File::Copy';
requires 'File::Spec';
requires 'HTML::Scrubber';
requires 'List::MoreUtils';
requires 'Locale::Maketext::Simple';
requires 'Module::Pluggable';
requires 'Regexp::Copy';
requires 'Regexp::Common';
requires 'Scalar::Util';
requires 'Storable' => '2.05';
requires 'Template';
requires 'YAML::Syck';

my $msg = "Use Template::Alloy for improved performance over Template.pm ?
(see docs for enabling this at runtime)";

feature $msg, 
    -default => 0,
    'Template::Alloy' => '1.005';

build_requires 'Test::NoWarnings';

no_index directory => 'examples';

tests 't/*.t t/*/*.t';

auto_install();
&WriteAll;
