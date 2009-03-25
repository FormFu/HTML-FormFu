use inc::Module::Install 0.75;

name 'HTML-FormFu';
perl_version '5.008001';
all_from 'lib/HTML/FormFu.pm';

# this is the lowest version of Exporter I can identify that exports import()
# it's bundled with perl 5.83
# version 5.567 that ships with perl 5.82 is no good
requires 'Exporter' => '5.57';

requires 'Captcha::reCAPTCHA' => 0.92;
requires 'Class::Accessor::Chained::Fast';
requires 'Class::C3';
requires 'Config::Any' => '0.10'; # supports multi-doc config files
requires 'Crypt::CBC';
requires 'Crypt::DES';
requires 'Data::Visitor::Callback';
requires 'Date::Calc';
requires 'DateTime' => '0.38'; # required for string overloading
requires 'DateTime::Format::Strptime';  
requires 'DateTime::Format::Builder' => '0.7901'; # fixes memory leaks
requires 'DateTime::Format::Natural';
requires 'DateTime::Locale';
requires 'Email::Valid';
requires 'File::ShareDir';
requires 'Hash::Flatten';
requires 'HTML::Scrubber';
requires 'HTML::TokeParser::Simple' => '3.14';
requires 'HTTP::Headers' => '1.64';
requires 'List::Util';
requires 'List::MoreUtils';
requires 'Locale::Maketext';
requires 'Module::Pluggable';
requires 'Number::Format';
requires 'Readonly';
requires 'Regexp::Copy';
requires 'Regexp::Common';
requires 'Path::Class::File';
requires 'Task::Weaken'; # to ensure Scalar::Util was built with weaken()
requires 'Template'; # form->start and ->end still require TT
                     # so does t/elements/render_method
requires 'YAML::Syck' => '1.05';

test_requires 'CGI'; # for file POST tests
test_requires 'Test::NoWarnings';

tests_recursive( 't' );

no_index directory => 'examples';

install_script('bin/html_formfu_deploy.pl');
install_script('bin/html_formfu_dumpconf.pl');
install_share();

&WriteAll;
