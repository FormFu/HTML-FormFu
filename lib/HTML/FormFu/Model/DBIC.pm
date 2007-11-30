package HTML::FormFu::Model::DBIC;
use strict;
use warnings;

use Storable qw( dclone );
use Carp qw( croak );

sub values_from_model {
    my ( $self, $base, $dbic, $attrs ) = @_;

    $attrs ||= {};

    my $form = $base->form;
    
    $base = $form->get_all_element({ nested_name => $attrs->{nested_base} })
        if defined $attrs->{nested_base}
        && ( !defined $base->nested_name
            || $base->nested_name ne $attrs->{nested_base} );

    my $rs   = $dbic->result_source;
    my @rels = $rs->relationships;
    my @cols = $rs->columns;

    _fill_relationships( $self, $base, $dbic, $form, $rs, $attrs, \@rels );
    
    _fill_columns( $base, $dbic, $attrs, \@rels, \@cols );
    
    _fill_multi_value_fields_many_to_many(
        $base, $dbic, $attrs, \@rels, \@cols );
    
    _fill_repeatable_many_to_many(
        $self, $base, $dbic, $form, $rs, $attrs, \@rels, \@cols );
    
    return $form;
}

sub _fill_relationships {
    my ( $self, $base, $dbic, $form, $rs, $attrs, $rels ) = @_;
    
    for my $rel ( @$rels ) {
        if ( defined $attrs->{from}
             && $attrs->{from} eq $rs->related_source($rel)->result_class )
        {
            next;
        }
        
        my ($block) = grep { !$_->is_field }
            @{ $base->get_all_elements({ nested_name => $rel }) };
        
        my ($field) = grep {
                defined $attrs->{nested_base}
                    ? $_->parent->nested_name eq $attrs->{nested_base}
                    : !$_->nested
            } @{ $base->get_fields({ name => $rel }) };

        if ( defined $block && $block->is_repeatable ) {
            # Handle has_many
            
            next unless $block->increment_field_names;
            
            # check there's a field name matching the PK
            
            my ($pk) = $rs->related_source($rel)->primary_columns;
            
            next unless grep {
                $_->name eq $pk
            } @{ $block->get_fields({ type => 'Hidden' }) };
            
            my @rows   = $dbic->related_resultset($rel)->all;
            my $count  = $block->db->{new_empty_row}
                         ? scalar @rows + 1
                         : scalar @rows;
            
            my $blocks = $block->repeat( $count );
            
            for my $rep ( 0 .. $#rows ) {
                values_from_model(
                    $self,
                    $blocks->[$rep],
                    $rows[$rep],
                    {
                        %$attrs,
                        repeat_base => $rel,
                        from        => $rs->result_class,
                    });
            }
            
            # set the counter field to the number of rows
            
            if ( defined ( my $param_name = $block->query_param ) ) {
                my $field = $form->get_field($param_name);
                
                $field->default( $count )
                    if defined $field;
            }
        }
        elsif ( defined $block ) {
            # Handle 'might_have' and 'has_one'

            if ( defined( my $row = $dbic->$rel ) ) {
                values_from_model(
                    $self,
                    $block,
                    $row,
                    {
                        %$attrs,
                        nested_base => $rel,
                    });
            }
        }
#        elsif ( defined $field && !grep { $rel eq $_ } @cols ) {
#            # Handle 'belongs_to' relationships
#
#            if ( defined( my $row = $dbic->$rel ) ) {
#                # will break with multi-column PKs
#
#                my $rel  = $rs->related_source($rel);
#                my ($pk) = $rel->primary_columns;
#                
#                $field->default( $row->$pk );
#            }
#        }
    }
    return;
}

sub _fill_columns {
    my ( $base, $dbic, $attrs, $rels, $cols ) = @_;
    
    for my $col ( @$cols ) {
        my $field;
        if ( defined $attrs->{repeat_base} ) {
            for my $f ( @{ $base->get_fields } ) {
                next unless $f->nested_base eq $attrs->{repeat_base};
                my $orig = $f->original_name;
                next unless defined $orig && $orig eq $col;
                $field = $f;
                last;
            }
        }
        else {
            ($field) = grep {
                defined $attrs->{nested_base}
                    ? $_->nested_base eq $attrs->{nested_base}
                    : !$_->nested
            } @{ $base->get_fields({ name => $col }) };
        }
        
        next if !defined $field;
        
        if ( grep { $col eq $_ } @$rels ) {
            # relationship of the same name, can't use accessor
            
            $field->default( $dbic->get_column($col) );
        }
        else {
            $field->default( $dbic->$col );
        }
    }
    return;
}

sub _fill_multi_value_fields_many_to_many {
    my ( $base, $dbic, $attrs, $rels, $cols ) = @_;
    
    my @fields = grep {
            defined $attrs->{nested_base}
                ? $_->parent->nested_name eq $attrs->{nested_base}
                : !$_->nested
        } 
        grep { $_->multi_value }
        grep { defined $_->name }
        @{ $base->get_fields };

    for my $field (@fields) {
        my $name = $field->name;
        
        next if grep { $name eq $_ } @$rels, @$cols;
        
        if ( $dbic->can($name) ) {
            my ($col) = exists $field->db->{default_column}
                ? $field->db->{default_column}
                : $dbic->$name->result_source->primary_columns;
            
            my @defaults = $dbic->$name->get_column($col)->all;
            
            $field->default(\@defaults);
        }
    }
    return;
}

sub _fill_repeatable_many_to_many {
    my ( $self, $base, $dbic, $form, $rs, $attrs, $rels, $cols ) = @_;
    
    my @blocks = grep {
            !$_->is_field
            && $_->is_repeatable
            && $_->increment_field_names
        }
        @{ $base->get_all_elements };

    for my $block (@blocks) {
        my $rel = $block->nested_name;
        
        next if grep { $rel eq $_ } @$rels, @$cols;
        
        if ( $dbic->can($rel) ) {
            # check there's a field name matching the PK
            
            my ($pk) = $dbic->$rel->result_source->primary_columns;
            
            next unless grep {
                $_->name eq $pk
            } @{ $block->get_fields({ type => 'Hidden' }) };
            
            my @rows   = $dbic->$rel->all;
            my $count  = $block->db->{new_empty_row}
                         ? scalar @rows + 1
                         : scalar @rows;
            
            my $blocks = $block->repeat( $count );
            
            for my $rep ( 0 .. $#rows ) {
                values_from_model(
                    $self,
                    $blocks->[$rep],
                    $rows[$rep],
                    {
                        %$attrs,
                        repeat_base => $rel,
                        from        => $rs->result_class,
                    });
            }
            
            # set the counter field to the number of rows
            
            if ( defined ( my $param_name = $block->query_param ) ) {
                my $field = $form->get_field($param_name);
                
                $field->default( $count )
                    if defined $field;
            }
        }
    }
    return;
}

sub save_to_model {
    my ( $self, $base, $dbic, $attrs ) = @_;

    $attrs ||= {};
    
    my $form = $base->form;
    
    $base = $form->get_all_element({ nested_name => $attrs->{nested_base} })
        if defined $attrs->{nested_base}
        && ( !defined $base->nested_name
            || $base->nested_name ne $attrs->{nested_base} );

    my %checkbox = map { $_->nested_name => 1 }
        grep { defined $_->name }
        @{ $base->get_fields( { type => 'Checkbox' } ) || [] };

    my $rs    = $dbic->result_source;
    my @rels  = $rs->relationships;
    my @cols  = $rs->columns;
    
    _save_relationships( $self, $base, $dbic, $form, $rs, $attrs, \@rels );
    
    _save_columns( $base, $dbic, $form, $attrs, \%checkbox, \@rels, \@cols );
    
    _save_multi_value_fields_many_to_many(
        $base, $dbic, $form, $attrs, \@rels, \@cols );
    
    _save_repeatable_many_to_many(
        $self, $base, $dbic, $form, $attrs, \@rels, \@cols );
    
    $dbic->update_or_insert;

    return $dbic;
}

sub _save_relationships {
    my ( $self, $base, $dbic, $form, $rs, $attrs, $rels ) = @_;
    
    return if $attrs->{no_follow};
    
    for my $rel ( @$rels ) {
        
        # don't follow rels to where we came from
        next if defined $attrs->{from}
            && $attrs->{from} eq $rs->related_source($rel)->result_class;
        
        my ($block) = grep { !$_->is_field }
            @{ $base->get_all_elements({ nested_name => $rel }) };
        
        next if !defined $block;
        next if !$form->valid($rel);
        
        my $params = $form->param($rel);
        
        if ( $block->is_repeatable ) {
            # Handle has_many
            
            _save_has_many( $self, $dbic, $form, $rs, $block, $rel, $attrs );
            
        }
        elsif ( ref $params eq 'HASH' ) {
            my $target = $dbic->find_or_new_related( $rel, {} );
            
            save_to_model(
                $self,
                $block,
                $target,
                {
                    %$attrs,
                    nested_base => $rel,
                    from        => $dbic->result_class,
                } );
        }
    }
}

sub _save_has_many {
    my ( $self, $dbic, $form, $rs, $block, $rel, $attrs ) = @_;
    
    return unless $block->increment_field_names;
            
    # check there's a field name matching the PK
    
    my ($pk) = $rs->related_source($rel)->primary_columns;
    
    return unless grep {
        $_->original_name eq $pk
    } @{ $block->get_fields({ type => 'Hidden' }) };
    
    my @blocks = @{ $block->get_elements };
    my $max    = $#blocks;
    
    # iterate over blocks, not rows
    # new rows might have been created in the meantime
    
    for my $i (0..$max) {
        my $rep = $blocks[$i];
        # find PK field
        
        my ($pk_field) = grep {
            $_->original_name eq $pk
        } @{ $rep->get_fields({ type => 'Hidden' }) };
        
        next if !defined $pk_field;
        
        my $value = $form->param( $pk_field->nested_name );
        my $row;
        
        if ( ( !defined $value || $value eq '' )
             && $i == $max
             && $block->db->{new_empty_row} )
        {
            # insert a new row
            $row = _insert_has_many( $dbic, $form, $block, $rep, $rel );
            
            next if !defined $row;
        }
        elsif ( !defined $value || $value eq '' ) {
            next;
        }
        else {
            $row = $dbic->find_related( $rel, $value );
        }
        next if !defined $row;
        
        # should we delete the row?
        
        next if _delete_has_many( $form, $row, $rep );
        
        save_to_model(
            $self,
            $rep,
            $row,
            {
                %$attrs,
                repeat_base => $rel,
                from        => $dbic->result_class,
            });
    }
}

sub _insert_has_many {
    my ( $dbic, $form, $outer, $repetition, $rel ) = @_;
    
    my $rows = ref $outer->db->{new_empty_row} eq 'ARRAY'
        ? $outer->db->{new_empty_row}
        : [ $outer->db->{new_empty_row} ];
    
    for my $name (@$rows) {
        my ($field) = grep {
            $_->original_name eq $name
        } @{ $repetition->get_fields };
        
        return if !defined $field;
        
        my $nested_name = $field->nested_name;
        return if !$form->valid($nested_name);
        
        my $value = $form->param( $nested_name );
        return if !length $value;
    }
    
    my $row = $dbic->new_related( $rel, {} );
    
    return $row;
}

sub _delete_has_many {
    my ( $form, $row, $rep ) = @_;
    
    my ($del_field) = grep {
        $_->db->{delete_if_true}
    } @{ $rep->get_fields };
    
    return if !defined $del_field;
    
    my $nested_name = $del_field->nested_name;
    
    return unless $form->valid($nested_name)
        && $form->param($nested_name);
    
    $row->delete;
    
    return 1;
}

sub _save_columns {
    my ( $base, $dbic, $form, $attrs, $checkbox, $rels, $cols ) = @_;
    
    my @valid = $form->valid;
    
    my @pk = $dbic->result_source->primary_columns;
    
    for my $col (@$cols) {
        # don't edit primary key columns
        next if grep { $col eq $_ } @pk;
        
        my $col_info    = $dbic->column_info($col);
        my $is_nullable = $col_info->{is_nullable} || 0;
        my $data_type   = $col_info->{data_type} || '';
        my $field;
        if ( defined $attrs->{repeat_base} ) {
            for my $f ( @{ $base->get_fields } ) {
                next unless $f->nested_base eq $attrs->{repeat_base};
                my $orig = $f->original_name;
                next unless defined $orig && $orig eq $col;
                $field = $f;
                last;
            }
        }
        else {
            $field = $base->get_field({ name => $col });
        }

        my $nested_name = defined $field ? $field->nested_name : undef;

        my $value = defined $field
            ? $form->param( $field->nested_name )
            : ( grep { $col eq $_ } @valid )
                ? $form->param( $col )
                : undef;

        if ( ( $is_nullable
            || $data_type =~ m/^timestamp|date|int|float|numeric/i
            )
            && defined $value && $value eq ''
          )
        {
            $value = undef;
        }
        elsif ( defined $nested_name 
            && $checkbox->{$nested_name}
            && !defined $value
            && !$is_nullable )
        {
            $value = $col_info->{default_value};
        }
        elsif ( defined $value
            || ( defined $nested_name && $checkbox->{$nested_name} ) )
        {
            # keep $value
        }
        else {
            next;
        }
        
        if ( grep { $col eq $_ } @$rels ) {
            # relationship of the same name, can't use accessor
            
            $dbic->set_column( $col, $value );
        }
        else {
            $dbic->$col($value);
        }
    }
}

sub _save_multi_value_fields_many_to_many {
    my ( $base, $dbic, $form, $attrs, $rels, $cols ) = @_;
    
    my @fields = grep {
            defined $attrs->{nested_base}
                ? $_->parent->nested_name eq $attrs->{nested_base}
                : !$_->nested
        } 
        grep { $_->multi_value }
        grep { defined $_->name }
        @{ $base->get_fields };

    for my $field (@fields) {
        my $name = $field->name;
        
        next if grep { $name eq $_ } @$rels, @$cols;
        
        if ( $dbic->can($name) ) {
            my $nested_name = $field->nested_name;
            
            next unless $form->valid($nested_name);
            
            my @values = $form->param($nested_name);
            
            my ($pk) = $dbic->$name->result_source->primary_columns;
            
            my @rows = $dbic->$name->result_source->resultset
                ->search( { "me.$pk" => { -in => \@values } } )->all;
            
            my $set_method = "set_$name";
            
            $dbic->$set_method( \@rows );
        }
    }
}

sub _save_repeatable_many_to_many {
    my ( $self, $base, $dbic, $form, $attrs, $rels, $cols ) = @_;
    
    my @blocks = grep {
            !$_->is_field
            && $_->is_repeatable
            && $_->increment_field_names
        }
        @{ $base->get_all_elements };
    
    for my $block (@blocks) {
        my $rel = $block->nested_name;
        
        next if grep { $rel eq $_ } @$rels, @$cols;
        
        if ( $dbic->can($rel) ) {
            # check there's a field name matching the PK
            
            my ($pk) = $dbic->$rel->result_source->primary_columns;
            
            my @blocks = @{ $block->get_elements };
            my $max    = $#blocks;
            
            # iterate over blocks, not rows
            # new rows might have been created in the meantime
            
            for my $i (0..$max) {
                my $rep = $blocks[$i];
                # find PK field
                
                my ($pk_field) = grep {
                    $_->original_name eq $pk
                } @{ $rep->get_fields({ type => 'Hidden' }) };
                
                next if !defined $pk_field;
                
                my $value = $form->param( $pk_field->nested_name );
                my $row;
                my $is_new;
                
                if ( ( !defined $value || $value eq '' )
                     && $i == $max
                     && $block->db->{new_empty_row} )
                {
                    # insert a new row
                    $row = _insert_many_to_many(
                        $dbic, $form, $block, $rep, $rel );
                    
                    next if !defined $row;
                    
                    $is_new = 1;
                }
                elsif ( !defined $value || $value eq '' ) {
                    next;
                }
                else {
                    $row = $dbic->$rel->find($value);
                }
                next if !defined $row;
                
                # should we delete the row?
                
                next if _delete_many_to_many( $form, $dbic, $row, $rel, $rep );
                
                save_to_model(
                    $self,
                    $rep,
                    $row,
                    {
                        %$attrs,
                        repeat_base => $rel,
                        from        => $dbic->result_class,
                    });
                
                if ($is_new) {
                    # new rows need to be related
                    my $add_method = "add_to_$rel";
                    
                    $dbic->$add_method($row);
                }
            }
        }
    }
    return;
}

sub _insert_many_to_many {
    my ( $dbic, $form, $outer, $repetition, $rel ) = @_;
    
    my $rows = ref $outer->db->{new_empty_row} eq 'ARRAY'
        ? $outer->db->{new_empty_row}
        : [ $outer->db->{new_empty_row} ];
    
    for my $name (@$rows) {
        my ($field) = grep {
            $_->original_name eq $name
        } @{ $repetition->get_fields };
        
        return if !defined $field;
        
        my $nested_name = $field->nested_name;
        return if !$form->valid($nested_name);
        
        my $value = $form->param( $nested_name );
        return if !length $value;
    }
    
    my $row = $dbic->$rel->result_source->new( {} );
    
    # add_to_* will be called later, after save_to_model is called on this row
    
    return $row;
}

sub _delete_many_to_many {
    my ( $form, $dbic, $row, $rel, $rep ) = @_;
    
    my ($del_field) = grep {
        $_->db->{unrelate_if_true}
    } @{ $rep->get_fields };
    
    return if !defined $del_field;
    
    my $nested_name = $del_field->nested_name;
    
    return unless $form->valid($nested_name)
        && $form->param($nested_name);
    
    my $remove = "remove_from_$rel";
    
    $dbic->$remove($row);
    
    return 1;
}

1;

__END__

=head1 NAME

HTML::FormFu::Model::DBIC - Integrate HTML::FormFu with DBIx::Class

=head1 SYNOPSIS

Set a form's default values from a DBIx::Class row object:

    my $row = $resultset->find( $id );
    
    $form->values_from_model( $row );

Update the database from a submitted form:

    if ( $form->submitted_and_valid ) {
        my $row = $resultset->find( $form->param('id') );
        
        $form->save_to_model( $row );
    }

=head1 METHODS

=head2 values_from_model

Arguments: $dbic_row, [\%config]

Return Value: $form

=head2 save_to_model

Arguments: $dbic_row, [\%config]

Return Value: $dbic_row

Update the database with the submitted form values. Uses 
L<update_or_insert|DBIx::Class::Row/update_or_insert>.

=head2 Example

A single form containing 2 addresses, both of which should be stored in the 
same database table:

    ---
    elements:
      - type: Fieldset
        nested_name: home
        elements:
          - name: street
          - name: city
          - name: code
      - type: Fieldset
        nested_name: office
        elements:
          - name: street
          - name: city
          - name: code

This will result in the form fields being named:

    home.street
    home.city
    home.code
    office.street
    office.city
    office.code

The form could then be used like so:

    my $home = $user->new_related( 'address', { type => 'home' } );
    
    $home->populate_from_formfu( $form, { nested_base => 'home' } );
    
    my $office = $user->new_related( 'address', { type => 'home' } );
    
    $office->populate_from_formfu( $form, { nested_base => 'office' } );

=head1 FREQUENTLY ASKED QUESTIONS (FAQ)

=head2 Add extra values not in the form

To send extra values to the database, which weren't submitted to the form, 
you can first add them to the form with L<add_valid|HTML::FormFu/add_valid>.

    my $passwd = generate_passwd();
    
    $form->add_valid( passwd => $passwd );
    
    $row->populate_from_formfu( $form );

C<add_valid> works for fieldnames that don't exist in the form.

=head1 CAVEATS

To ensure your column's inflators and deflators are called, we have to 
get / set values using their named methods, and not with C<get_column> / 
C<set_column>.

Because of this, beware of having column names which clash with DBIx::Class 
built-in method-names, such as C<delete>. - It will have obviously 
undesirable results!

=head1 SUPPORT

Project Page:

L<http://code.google.com/p/html-formfu/>

Mailing list:

L<http://lists.scsys.co.uk/cgi-bin/mailman/listinfo/html-formfu>

Mailing list archives:

L<http://lists.scsys.co.uk/pipermail/html-formfu/>

=head1 BUGS

Please submit bugs / feature requests to 
L<http://code.google.com/p/html-formfu/issues/list> (preferred) or 
L<http://rt.perl.org>.

=head1 SUBVERSION REPOSITORY

The publicly viewable subversion code repository is at 
L<http://html-formfu.googlecode.com/svn/trunk/HTML-FormFu-Model-DBIC>.

If you wish to contribute, you'll need a GMAIL email address. Then just 
ask on the mailing list for commit access.

If you wish to contribute but for some reason really don't want to sign up 
for a GMAIL account, please post patches to the mailing list (although  
you'll have to wait for someone to commit them). 

If you have commit permissions, use the HTTPS repository url: 
L<https://html-formfu.googlecode.com/svn/trunk/HTML-FormFu-Model-DBIC>

=head1 SEE ALSO

L<HTML::FormFu>, L<DBIx::Class>, L<Catalyst::Controller::HTML::FormFu>

=head1 AUTHOR

Carl Franks

=head1 CONTRIBUTORS

Based on the code of C<DBIx::Class::HTML::FormFu>, which was contributed to
by:

Adam Herzog

Daisuke Maki

Mario Minati

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Carl Franks

Based on the original source code of L<DBIx::Class::HTMLWidget>, copyright 
Thomas Klausner.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
