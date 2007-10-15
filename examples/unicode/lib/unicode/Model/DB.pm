package unicode::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'unicode::Schema',
    connect_info => [
        'dbi:SQLite:dbname=unicode.db',
        
    ],
    
);

=head1 NAME

unicode::Model::DB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<unicode>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<dbi:SQLite:dbname=unicode.db>

=head1 AUTHOR

Carl Franks

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
