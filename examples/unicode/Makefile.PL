use inc::Module::Install;

name 'unicode';
all_from 'lib/unicode.pm';

requires 'Catalyst' => '5.7008';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::Controller::HTML::FormFu';
requires 'Catalyst::Action::RenderView';
requires 'DBIx::Class::Schema';
requires 'YAML::Syck';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
