package HTML::FormFu::Element::radiogroup;

use strict;
use warnings;
use base 'HTML::FormFu::Element::group';

use HTML::FormFu::Util qw( append_xml_attribute );

__PACKAGE__->mk_accessors(qw/ radiogroup_filename /);

sub new {
    my $self = shift->SUPER::new(@_);

    $self->filename('radiogroup');
    $self->radiogroup_filename('radiogroup_tag');
    $self->label_filename('legend');
    $self->container_tag('fieldset');

    return $self;
}

sub prepare_id {
    my ( $self, $render ) = @_;

    my $form_id    = defined $self->form->id ? $self->form->id : '';
    my $field_name = defined $self->name     ? $self->name     : '';
    my $count      = 0;

    for my $option ( @{ $render->{options} } ) {
        if ( exists $option->{group} ) {
            for my $item ( @{ $option->{group} } ) {
                $self->_prepare_id( $item, $form_id, $field_name, \$count );
            }
        }
        else {
            $self->_prepare_id( $option, $form_id, $field_name, \$count );
        }
    }

    return;
}

sub _prepare_id {
    my ( $self, $option, $form_id, $field_name, $count_ref ) = @_;

    if ( !exists $option->{attributes}{id} && defined $self->auto_id ) {
        my %string = (
            f => $form_id,
            n => $field_name,
        );

        my $id = $self->auto_id;
        $id =~ s/%([fn])/$string{$1}/g;
        $id =~ s/%c/ ++$$count_ref /gex;

        $option->{attributes}{id} = $id;
    }

    # label "for" attribute
    if (   exists $option->{label}
        && exists $option->{attributes}{id}
        && !exists $option->{label_attributes}{for} )
    {
        $option->{label_attributes}{for} = $option->{attributes}{id};
    }

    return;
}

sub _prepare_attrs {
    my ( $self, $submitted, $value, $default, $option ) = @_;

    if ( $submitted
         && defined $value
         && ( ref $value eq 'ARRAY'
            ? grep { $_ eq $option->{value} } @$value
            : $value eq $option->{value} ) )
    {
        $option->{attributes}{checked} = 'checked';
    }
    elsif ($submitted
        && $self->retain_default
        && ( !defined $value || $value eq "" )
        && $self->value eq $option->{value} )
    {
        $option->{attributes}{checked} = 'checked';
    }
    elsif ($submitted) {
        delete $option->{attributes}{checked};
    }
    elsif ( defined $default && $default eq $option->{value} ) {
        $option->{attributes}{checked} = 'checked';
    }

    return;
}

sub _render_label {
    my ( $self, $render ) = @_;
    
    $self->SUPER::_render_label($render);
    
    if ( defined $render->{label} && $render->{label_filename} eq 'legend' ) {
        $render->{container_attributes}{class} =~ s/\blabel\b/legend/;
    }
    
    return;
}

sub render {
    my $self = shift;

    my $render = $self->SUPER::render({
        radiogroup_filename => $self->radiogroup_filename,
        @_ ? %{$_[0]} : ()
        });

    for my $item ( @{ $render->{options} } ) {
        append_xml_attribute( $item->{attributes}, 'class', 'subgroup' )
            if exists $item->{group};
    }

    return $render;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::RadioGroup - Group of radiobutton form fields

=head1 SYNOPSIS

    my $e = $form->element( RadioGroup => 'foo' );

=head1 DESCRIPTION

Convenient to use group of radio button fields

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
