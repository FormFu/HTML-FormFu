package HTML::FormFu::Exception;
use Moose;

with 'HTML::FormFu::Role::Populate';

use HTML::FormFu::ObjectUtil qw( form parent );

sub BUILD { }
__PACKAGE__->meta->make_immutable;

1;
