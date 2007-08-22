use inc::Module::Install;

if ( -f 'MANIFEST.SKIP' ) {
    system( $^X, 'update_pm_from_templates.pl' ) == 0
	or die "update_pm_from_templates failed";
}

name 'HTML-FormFu';
all_from 'lib/HTML/FormFu.pm';

requires 'perl' => '5.8.1';
requires 'Carp';
requires 'Class::Accessor::Chained::Fast';
requires 'Class::C3';
requires 'Class::Data::Accessor';
requires 'Config::Any';
requires 'Date::Calc';
requires 'DateTime::Format::Builder';
requires 'DateTime::Format::Strptime';
requires 'DateTime::Locale';
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
requires 'Template' => '2.19';
requires 'YAML::Syck';

my $msg = "Use Template::Alloy for improved performance over Template.pm ?
(see docs for enabling this at runtime)";

feature $msg, 
    -default => 0,
    'Template::Alloy' => '1.005';

build_requires 'Test::NoWarnings';

tests 't/*.t t/*/*.t';

auto_install();
&WriteAll;
