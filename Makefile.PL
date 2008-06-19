use inc::Module::Install 0.75;

name 'HTML-FormFu';
perl_version '5.008001';
all_from 'lib/HTML/FormFu.pm';

requires 'Class::Accessor::Chained::Fast';
requires 'Class::C3';
requires 'Config::Any' => '0.10'; # supports multi-doc config files
requires 'Crypt::CBC';
requires 'Crypt::DES';
requires 'Data::Visitor::Callback';
requires 'Date::Calc';
requires 'DateTime' => '0.38'; # required for string overloading
requires 'DateTime::Format::Builder' => '0.7901'; # fixes memory leaks
requires 'DateTime::Format::Natural';
requires 'DateTime::Format::Strptime';
requires 'DateTime::Locale';
requires 'Email::Valid';
requires 'File::ShareDir';
requires 'HTML::Scrubber';
requires 'HTML::TokeParser::Simple' => '3.14';
requires 'HTTP::Headers' => '1.64';
requires 'List::MoreUtils';
requires 'Locale::Maketext::Simple';
requires 'Module::Pluggable';
requires 'Regexp::Copy';
requires 'Regexp::Common';
requires 'Task::Weaken'; # to ensure Scalar::Util was built with weaken()
requires 'Template'; # form->start and ->end still require TT
                     # so does t/elements/render_method
requires 'YAML::Syck';

test_requires 'Test::NoWarnings';

tests 't/*.t t/*/*.t';

no_index directory => 'examples';

install_script('bin/html_formfu_deploy.pl');
install_share();

auto_install();
&WriteAll;
