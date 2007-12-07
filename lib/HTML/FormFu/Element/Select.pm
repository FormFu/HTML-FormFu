package HTML::FormFu::Element::Select;

use strict;
use base 'HTML::FormFu::Element::_Group';
use Class::C3;

use HTML::FormFu::Util qw( append_xml_attribute process_attrs );

__PACKAGE__->mk_attr_accessors(qw/ multiple size /);

sub new {
    my $self = shift->next::method(@_);

    $self->filename('input');
    $self->field_filename('select_tag');
    $self->multi_value(1);

    return $self;
}

sub process {
    my ($self) = @_;
    
    my $context = $self->form->stash->{context};
    my $args    = $self->db;
    
    if ( $args && $args->{schema} && $context ) {
        my $model = $context->model( $args->{schema} );
        return if !defined $model;
        
        $model = $model->resultset( $args->{resultset} )
            if defined $args->{resultset};
        
        my $rs    = $model->result_source;
        my $id    = $args->{id_column};
        my $label = $args->{label_column};
        
        if ( !defined $id ) {
            ($id) = $rs->primary_columns;
        }
        
        if ( !defined $label ) {
            # use first text column
            ($label) = grep {
                $rs->column_info($_)->{data_type} =~ /text|varchar/i
            } $rs->columns;
        }
        return if !defined $label;
        
        my $result = $model->search( {}, { -columns => [$id, $label] } );
        
        my @defaults = map {
            [ $_->$id, $_->$label ]
        } $result->all;
        
        $self->options( \@defaults );
    }
}

sub _prepare_attrs {
    my ( $self, $submitted, $value, $default, $option ) = @_;

    if (   $submitted
        && defined $value
        && (ref $value eq 'ARRAY'
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
    elsif ( defined $default
        && (ref $default eq 'ARRAY'
            ? grep { $_ eq $option->{value} } @$default
            : $default eq $option->{value} ) ) {
        $option->{attributes}{selected} = 'selected';
    }
    return;
}

sub _string_field {
    my ( $self, $render ) = @_;
    
    # select_tag template
    
    my $html .= sprintf qq{<select name="%s"%s>\n}, 
        $render->{nested_name}, 
        process_attrs( $render->{attributes} );
    
    for my $option (@{ $render->{options} }) {
        if ( exists $option->{group} ) {
            $html .= "<optgroup";
            
            if ( defined $option->{label} ) {
                $html .= sprintf qq{ label="%s"}, 
                    $option->{label};
            }
            
            $html .= sprintf "%s>\n", 
                process_attrs( $option->{attributes} );
            
            for my $item (@{ $option->{group} }) {
                $html .= sprintf qq{<option value="%s"%s>%s</option>\n}, 
                    $item->{value}, 
                    process_attrs( $item->{attributes} ), 
                    $item->{label};
            }
            
            $html .= "</optgroup>\n";
        }
        else {
            $html .= sprintf qq{<option value="%s"%s>%s</option>\n}, 
                $option->{value}, 
                process_attrs( $option->{attributes} ), 
                $option->{label};
        }
    }
    
    $html .= "</select>";
    
    return $html;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Select - Select form field

=head1 SYNOPSIS

YAML config:

    ---
    elements:
      - type: Select
        name: sex
        options:
          - [ 'm', 'Male' ]
          - [ 'f', 'Female' ]

=head1 DESCRIPTION

Select form field.

Supports optgroups, see L<HTML::FormFu::Element::_Group/options> for 
details.

=head1 METHODS

=head2 options

See L<HTML::FormFu::Element::_Group/options>.

=head2 values

See L<HTML::FormFu::Element::_Group/values>.

=head2 value_range

See L<HTML::FormFu::Element::_Group/value_range>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Group>, 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
