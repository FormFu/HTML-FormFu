# This file is a modified copy of MooseX/Attribute/Chained.pm
# Carl Franks 2014

#
# This file is part of MooseX-Attribute-Chained
#
# This software is copyright (c) 2012 by Moritz Onken.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use strict;
package MooseX::Attribute::FormFuChained;


# ABSTRACT: Attribute that returns the instance to allow for chaining
use Moose::Util;
Moose::Util::meta_attribute_alias(
    FormFuChained => 'MooseX::Traits::Attribute::FormFuChained' );

use strict;
package MooseX::Traits::Attribute::FormFuChained;


use Moose::Role;

override accessor_metaclass => sub {
    'MooseX::Attribute::FormFuChained::Method::Accessor';
};

use strict;
package MooseX::Attribute::FormFuChained::Method::Accessor;


use Carp qw(confess);
use Syntax::Keyword::Try;
use base 'Moose::Meta::Method::Accessor';

sub _generate_accessor_method_inline {
    my $self = shift;
    my $attr = $self->associated_attribute;
    my $clone
        = $attr->associated_class->has_method("clone")
        ? '$_[0]->clone'
        : 'bless { %{$_[0]} }, ref $_[0]';

    if ( $Moose::VERSION >= 1.9900 ) {
        try {
            return $self->_compile_code(
                [   'sub {',
                    'if (@_ > 1) {',
                    $attr->_inline_set_value( '$_[0]', '$_[1]' ),
                    'return $_[0];',
                    '}',
                    $attr->_inline_get_value('$_[0]'),
                    '}',
                ]
            );
        }
        catch {
            confess "Could not generate inline accessor because : $@";
        }
    }
    else {
        return $self->next::method(@_);
    }
}

sub _generate_writer_method_inline {
    my $self = shift;
    my $attr = $self->associated_attribute;
    my $clone
        = $attr->associated_class->has_method("clone")
        ? '$_[0]->clone'
        : 'bless { %{$_[0]} }, ref $_[0]';
    if ( $Moose::VERSION >= 1.9900 ) {
        try {
            return $self->_compile_code(
                [   'sub {', $attr->_inline_set_value( '$_[0]', '$_[1]' ),
                    '$_[0]', '}',
                ]
            );
        }
        catch {
            confess "Could not generate inline writer because : $@";
        }
    }
    else {
        return $self->next::method(@_);
    }
}

sub _inline_post_body {
    return 'return $_[0] if (scalar(@_) >= 2);' . "\n";
}

1;
