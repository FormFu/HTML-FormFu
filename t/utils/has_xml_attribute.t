use strict;
use warnings;

use Test::More tests => 17;

use HTML::FormFu::Util qw(
    literal
    has_xml_attribute
    xml_escape
);

{

    # has literal in literal
    my %attr = ( key => literal("<foo <bar <baz") );

    ok( has_xml_attribute( \%attr, "key", literal "<foo" ) );

    ok( has_xml_attribute( \%attr, "key", literal "<bar" ) );

    ok( has_xml_attribute( \%attr, "key", literal "<baz" ) );

    ok( !has_xml_attribute( \%attr, "key", literal "blank" ) );
}

{

    # has string in literal
    my %attr = ( key => literal("&lt;foo &lt;bar &lt;baz") );

    ok( has_xml_attribute( \%attr, "key", "<foo" ) );

    ok( has_xml_attribute( \%attr, "key", "<bar" ) );

    ok( has_xml_attribute( \%attr, "key", "<baz" ) );

    ok( !has_xml_attribute( \%attr, "key", "blank" ) );
}

{

    # has string in string
    my %attr = ( key => "<foo <bar <baz" );

    ok( has_xml_attribute( \%attr, "key", "<foo" ) );

    ok( has_xml_attribute( \%attr, "key", "<bar" ) );

    ok( has_xml_attribute( \%attr, "key", "<baz" ) );

    ok( !has_xml_attribute( \%attr, "key", "blank" ) );
}

{

    # has literal in string
    my %attr = ( key => "<foo <bar <baz" );

    ok( has_xml_attribute( \%attr, "key", literal "&lt;foo" ) );

    ok( has_xml_attribute( \%attr, "key", literal "&lt;bar" ) );

    ok( has_xml_attribute( \%attr, "key", literal "&lt;baz" ) );

    ok( !has_xml_attribute( \%attr, "key", literal "blank" ) );

    # ... has a string
    ok( has_xml_attribute( \%attr, "key", '<bar' ) );
}
