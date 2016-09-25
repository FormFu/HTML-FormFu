use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu::Util qw(
    literal
    append_xml_attribute
    xml_escape
);

{
    my %attr = ( foo => literal "<bar" );

    is( xml_escape( \%attr )->{foo}, "<bar" );

    # literal + literal
    append_xml_attribute( \%attr, "foo", literal ">baz" );

    is( xml_escape( \%attr )->{foo}, "<bar >baz" );

    # literal + string
    append_xml_attribute( \%attr, "foo", "<boo" );

    is( xml_escape( \%attr )->{foo}, "<bar >baz &lt;boo" );
}

{
    my %attr = ( foo => "<bar" );

    is( xml_escape( \%attr )->{foo}, "&lt;bar" );

    # string + string
    append_xml_attribute( \%attr, "foo", ">baz" );

    is( xml_escape( \%attr )->{foo}, "&lt;bar &gt;baz" );

    # string + literal
    append_xml_attribute( \%attr, "foo", literal "<boo" );

    is( xml_escape( \%attr )->{foo}, "&lt;bar &gt;baz <boo" );

    # ... + string
    append_xml_attribute( \%attr, "foo", '"bang' );

    is( xml_escape( \%attr )->{foo}, "&lt;bar &gt;baz <boo &#34;bang" );
}
