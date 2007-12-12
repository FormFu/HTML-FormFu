use inc::Module::Install;

name 'HTML-FormFu';
perl_version '5.008001';
all_from 'lib/HTML/FormFu.pm';

requires 'Class::Accessor::Chained::Fast';
requires 'Class::C3';
requires 'Config::Any' => '0.10'; # supports multi-doc config files
requires 'Data::Visitor::Callback';
requires 'Date::Calc';
requires 'DateTime::Format::Builder' => '0.7901'; # fixes memory leaks
requires 'DateTime::Format::Strptime';
requires 'DateTime::Locale';
requires 'Email::Valid';
requires 'File::ShareDir';
requires 'HTML::Scrubber';
requires 'HTML::TokeParser::Simple';
requires 'List::MoreUtils';
requires 'Locale::Maketext::Simple';
requires 'Module::Pluggable';
requires 'Regexp::Copy';
requires 'Regexp::Common';
requires 'Task::Weaken'; # to ensure Scalar::Util was built with weaken()
requires 'YAML::Syck';

my $msg = <<MSG;
If you want to use the template files to customise your forms,
you'll need to install one of the following modules:
MSG

feature "${msg}Template",
    -default => 0,
    'Template' => '2.19';

feature "Template::Alloy",
    -default => 0,
    'Template::Alloy' => '1.005';

test_requires 'Test::NoWarnings';

tests 't/*.t t/*/*.t';

no_index directory => 'examples';

install_script('bin/html_formfu_deploy.pl');
install_share();

auto_install();
&WriteAll;
