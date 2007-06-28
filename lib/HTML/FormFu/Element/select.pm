package HTML::FormFu::Element::select;

use strict;
use warnings;
use base 'HTML::FormFu::Element::group';

use HTML::FormFu::Util qw( append_xml_attribute );

__PACKAGE__->mk_attr_accessors(qw/ multiple size /);

sub new {
    my $self = shift->SUPER::new(@_);

    $self->filename('select');
    $self->field_filename('select_tag');
    $self->multi_filename('multi_ltr');

    return $self;
}

sub _prepare_attrs {
    my ( $self, $submitted, $value, $default, $option ) = @_;

    if ( $submitted
         && defined $value
         && ( ref $value eq 'ARRAY'
            ? grep { $_ eq $option->{value} } @$value
            : $value eq $option->{value} ) )
    {
        $option->{attributes}{selected} = 'selected';
    }
    elsif ($submitted
        && $self->retain_default
        && ( !defined $value || $value eq "" )
        && $self->value eq $option->{value} )
    {
        $option->{attributes}{selected} = 'selected';
    }
    elsif ($submitted) {
        delete $option->{attributes}{selected};
    }
    elsif ( defined $default && $default eq $option->{value} ) {
        $option->{attributes}{selected} = 'selected';
    }
    
    return;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Select - Select form field

=head1 SYNOPSIS

    my $element = $form->element( Select => 'foo' );

=head1 DESCRIPTION

Select form field.

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element::group>, 
L<HTML::FormFu::Element::field>, L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
