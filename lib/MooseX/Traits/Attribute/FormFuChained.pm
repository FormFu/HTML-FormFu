# This file is a modified copy of MooseX/Traits/Attribute/Chained.pm
# Carl Franks 2014

#
# This file is part of MooseX-Attribute-Chained
#
# This software is copyright (c) 2012 by Moritz Onken.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
package MooseX::Traits::Attribute::FormFuChained;
{
  $MooseX::Traits::Attribute::FormFuChained::VERSION = '1.0.1';
}
# ABSTRACT: DEPRECATED
use Moose::Role;
use MooseX::FormFuChainedAccessors;

sub accessor_metaclass { 'MooseX::FormFuChainedAccessors' }

no Moose::Role;
1;
