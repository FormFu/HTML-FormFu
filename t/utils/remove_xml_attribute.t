use strict;
use warnings;

use Test::More tests => 21;

use HTML::FormFu::Util qw(
    literal
    remove_xml_attribute
    xml_escape
);

{

    # remove literal from literal
    my %attr = ( key => literal("<foo <bar <foo <bar <foo") );

    is( xml_escape( \%attr )->{key}, "<foo <bar <foo <bar <foo" );

    remove_xml_attribute( \%attr, "key", literal "<foo" );

    is( xml_escape( \%attr )->{key}, "<bar <foo <bar <foo" );

    remove_xml_attribute( \%attr, "key", literal "<foo" );

    is( xml_escape( \%attr )->{key}, "<bar <bar <foo" );

    remove_xml_attribute( \%attr, "key", literal "<foo" );

    is( xml_escape( \%attr )->{key}, "<bar <bar" );

    remove_xml_attribute( \%attr, "key", literal "<bar" );

    is( xml_escape( \%attr )->{key}, "<bar" );

    remove_xml_attribute( \%attr, "key", literal "<bar" );

    is( xml_escape( \%attr )->{key}, "" );
}

{

    # remove string from literal
    my %attr = ( key => literal("&lt;foo &lt;bar &lt;foo &lt;bar &lt;foo") );

    is( xml_escape( \%attr )->{key},
        "&lt;foo &lt;bar &lt;foo &lt;bar &lt;foo" );

    remove_xml_attribute( \%attr, "key", "<foo" );

    is( xml_escape( \%attr )->{key}, "&lt;bar &lt;foo &lt;bar &lt;foo" );

    remove_xml_attribute( \%attr, "key", "<foo" );

    is( xml_escape( \%attr )->{key}, "&lt;bar &lt;bar &lt;foo" );

    remove_xml_attribute( \%attr, "key", "<foo" );

    is( xml_escape( \%attr )->{key}, "&lt;bar &lt;bar" );

    remove_xml_attribute( \%attr, "key", "<bar" );

    is( xml_escape( \%attr )->{key}, "&lt;bar" );

    remove_xml_attribute( \%attr, "key", "<bar" );

    is( xml_escape( \%attr )->{key}, "" );
}

{

    # remove string from string
    my %attr = ( key => "<foo <bar <foo <bar <foo" );

    is( xml_escape( \%attr )->{key},
        "&lt;foo &lt;bar &lt;foo &lt;bar &lt;foo" );

    remove_xml_attribute( \%attr, "key", "<foo" );

    is( xml_escape( \%attr )->{key}, "&lt;bar &lt;foo &lt;bar &lt;foo" );

    remove_xml_attribute( \%attr, "key", "<foo" );

    is( xml_escape( \%attr )->{key}, "&lt;bar &lt;bar &lt;foo" );

    remove_xml_attribute( \%attr, "key", "<foo" );

    is( xml_escape( \%attr )->{key}, "&lt;bar &lt;bar" );
}

{

    # remove literal from string
    my %attr = ( key => "<foo <bar <foo <bar <foo" );

    is( xml_escape( \%attr )->{key},
        "&lt;foo &lt;bar &lt;foo &lt;bar &lt;foo" );

    remove_xml_attribute( \%attr, "key", literal "&lt;foo" );

    is( xml_escape( \%attr )->{key}, "&lt;bar &lt;foo &lt;bar &lt;foo" );

    remove_xml_attribute( \%attr, "key", literal "&lt;foo" );

    is( xml_escape( \%attr )->{key}, "&lt;bar &lt;bar &lt;foo" );

    remove_xml_attribute( \%attr, "key", literal "&lt;foo" );

    is( xml_escape( \%attr )->{key}, "&lt;bar &lt;bar" );

    # ... remove a string
    remove_xml_attribute( \%attr, "key", '<bar' );

    is( xml_escape( \%attr )->{key}, "&lt;bar" );
}
