use strict;

package HTML::FormFu::Role::FormBlockAndFieldMethods;

use Moose::Role;

use HTML::FormFu::Attribute qw( mk_inherited_accessors );

our @MULTIFORM_SHARED = ( qw(
        auto_id
        auto_label
        auto_label_class
        auto_comment_class
        auto_container_class
        auto_container_label_class
        auto_container_comment_class
        auto_container_error_class
        auto_container_per_error_class
        auto_error_container_class
        auto_error_container_per_error_class
        auto_error_field_class
        auto_error_class
        auto_error_message
        auto_constraint_class
        auto_inflator_class
        auto_validator_class
        auto_transformer_class
        auto_datalist_id
        error_tag
        error_container_tag
        render_processed_value
        force_errors
        repeatable_count
        locale
) );

__PACKAGE__->mk_inherited_accessors(@MULTIFORM_SHARED);

1;

=head1 NAME

HTML::FormFu::Role::FormBlockAndFieldMethods

=head1 DESCRIPTION

Inherited Field methods.

=cut
