package HTML::FormFu::MultiForm;
use strict;

use HTML::FormFu;
use HTML::FormFu::Attribute qw/
    mk_attrs mk_attr_accessors
    mk_inherited_accessors mk_output_accessors
    mk_inherited_merging_accessors mk_accessors /;
use HTML::FormFu::ObjectUtil qw/
    populate load_config_file form
    clone stash parent
    get_nested_hash_value set_nested_hash_value nested_hash_key_exists /;

use HTML::FormFu::FakeQuery;
use Carp qw/ croak /;
use Crypt::CBC;
use List::MoreUtils qw( uniq );
use Scalar::Util qw/ blessed /;
use Storable qw/ dclone nfreeze thaw /;

use overload
    'eq' => sub { refaddr $_[0] eq refaddr $_[1] },
    'ne' => sub { refaddr $_[0] ne refaddr $_[1] },
    '==' => sub { refaddr $_[0] eq refaddr $_[1] },
    '!=' => sub { refaddr $_[0] ne refaddr $_[1] },
    '""' => sub { return shift->render },
    bool => sub {1},
    fallback => 1;

__PACKAGE__->mk_attrs(qw/ attributes crypt_args /);

__PACKAGE__->mk_attr_accessors(qw/ id action enctype method /);

# accessors shared with HTML::FormFu
our @ACCESSORS = qw/
    indicator filename javascript javascript_src
    element_defaults query_type languages force_error_message
    localize_class tt_module
    nested_name nested_subscript model_class
    auto_fieldset params_ignore_underscore stash_valid tmp_upload_dir
    /;

__PACKAGE__->mk_accessors(
    @ACCESSORS,
    qw/ query forms current_form_number current_form complete persist_stash
        multiform_hidden_name default_multiform_hidden_name combine_params
        _data _file_fields /
);

__PACKAGE__->mk_output_accessors(qw/ form_error_message /);

# accessors shared with HTML::FormFu
our @INHERITED_ACCESSORS = qw/
    auto_id auto_label auto_error_class auto_error_message
    auto_constraint_class auto_inflator_class auto_validator_class
    auto_transformer_class
    render_method render_processed_value force_errors repeatable_count
    /;

__PACKAGE__->mk_inherited_accessors(@INHERITED_ACCESSORS);

# accessors shared with HTML::FormFu
our @INHERITED_MERGING_ACCESSORS = qw/ tt_args config_callback /;

__PACKAGE__->mk_inherited_merging_accessors(@INHERITED_MERGING_ACCESSORS);

*loc = \&localize;

Class::C3::initialize();

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless {}, $class;

    my %defaults = (
        element_defaults      => {},
        tt_args               => {},
        stash                 => {},
        stash_valid           => [],
        persist_stash         => [],
        _file_fields          => [],
        languages             => ['en'],
        combine_params        => 1,
        default_multiform_hidden_name => '_multiform',
    );

    $self->populate( \%defaults );

    $self->populate( \%attrs );

    return $self;
}

sub process {
    my $self = shift;

    my $query;
    my $input;

    if (@_) {
        $query = shift;
        $self->query($query);
    }
    else {
        $query = $self->query;
    }
    
    my $name = $self->multiform_hidden_name;

    $name = $self->default_multiform_hidden_name
        if !defined $name;

    if ( defined $query && blessed($query) ) {
        $input = $query->param( $name );
    }
    elsif ( defined $query ) {

        # it's not an object, just a hashref

        $input = $self->get_nested_hash_value( $query, $name );
    }

    my $data = $self->_process_get_data($input);
    my $current_form_num;
    my @forms;

    eval { @forms = @{ $self->forms } };
    croak "forms() must be an arrayref" if $@;

    if ( defined $data ) {
        $current_form_num = $data->{current_form};

        my $current_form
            = $self->_load_current_form( $current_form_num, $data );

        # are we on the last form?
        # are we complete?

        if ( ( $current_form_num == scalar @forms )
            && $current_form->submitted_and_valid )
        {
            $self->complete(1);
        }
        
        $self->_data($data);
    }
    else {

        # default to first form

        $self->_load_current_form(1);
    }

    return;
}

sub _process_get_data {
    my ( $self, $input ) = @_;

    return unless defined $input && length $input;

    my $crypt = Crypt::CBC->new( %{ $self->crypt_args } );

    my $data;

    eval { $data = $crypt->decrypt_hex($input) };

    if ( defined $data ) {
        $data = thaw($data);

        $self->_file_fields( $data->{_file_fields} );
    }
    else {

        # should handle errors better

        $data = undef;
    }

    return $data;
}

sub _load_current_form {
    my ( $self, $current_form_num, $data ) = @_;

    my $current_form = HTML::FormFu->new;

    my $current_data = dclone( $self->forms->[ $current_form_num - 1 ] );

    # merge constructor args
    for my $key ( @ACCESSORS, @INHERITED_ACCESSORS,
        @INHERITED_MERGING_ACCESSORS )
    {
        my $value = $self->$key;

        $current_form->$key($value)
            if defined $value;
    }

    # copy attrs
    my $attrs = $self->attrs;

    for my $key ( keys %$attrs ) {
        $current_form->$key( $attrs->{$key} );
    }

    # copy stash
    my $stash = $self->stash;

    for my $key ( keys %$stash ) {
        $current_form->stash->{$key} = $stash->{$key}
    }

    # persist_stash
    if ( defined $data ) {
        for my $key ( @{ $self->persist_stash } ) {
            $current_form->stash->{$key} = $data->{persist_stash}{$key};
        }
    }

    # build form
    $current_form->populate($current_data);
    
    # add hidden field
    if ( ( !defined $self->multiform_hidden_name ) && $current_form_num > 1 ) {
        my $field = $current_form->element({
            type => 'Hidden',
            name => $self->default_multiform_hidden_name,
        });
        
        $field->constraint({
            type => 'Required',
        });
    }

    $current_form->query( $self->query );
    $current_form->process;

    # combine params
    if ( defined $data && $self->combine_params ) {

        my $params = $current_form->params;

        for my $name ( @{ $data->{valid_names} } ) {

            next if $self->nested_hash_key_exists( $params, $name );

            my $value = $self->get_nested_hash_value( $data->{params}, $name );

            # need to set upload object's parent manually
            # for now, parent points to the form
            # when formfu fixes this, this code will need updated
            _reparent_upload( $value, $current_form );

            $current_form->add_valid( $name, $value );
        }
    }

    $self->current_form_number($current_form_num);
    $self->current_form($current_form);

    return $current_form;
}

sub _reparent_upload {
    my ( $value, $form ) = @_;

    if ( ref $value eq 'ARRAY' ) {
        for my $value ( @$value ) {
            _reparent_upload( $value, $form );
        }
    }
    elsif ( blessed($value) && $value->isa('HTML::FormFu::Upload') ) {
        $value->parent($form);
    }

    return;
}

sub render {
    my $self = shift;

    my $form = $self->current_form;

    croak "process() must be called before render()"
        if !defined $form;

    if ( $self->complete ) {

        # why would you render if it's complete?
        # anyway, just show the last form

        return $form->render(@_);
    }

    if ( $form->submitted_and_valid ) {

        # return the next form

        return $self->next_form->render(@_);
    }

    # return the current form

    return $form->render(@_);
}

sub next_form {
    my ($self) = @_;

    my $form = $self->current_form;

    croak "process() must be called before next_form()"
        if !defined $form;

    my $current_form_num = $self->current_form_number;

    # is there a next form defined?
    return if $current_form_num >= scalar @{ $self->forms };

    my $form_data = dclone( $self->forms->[ $current_form_num ] );

    my $next_form = HTML::FormFu->new;

    # merge constructor args
    for my $key ( @ACCESSORS, @INHERITED_ACCESSORS,
        @INHERITED_MERGING_ACCESSORS )
    {
        my $value = $self->$key;

        $next_form->$key($value)
            if defined $value;
    }

    # copy attrs
    my $attrs = $self->attrs;

    for my $key ( keys %$attrs ) {
        $next_form->$key( $attrs->{$key} );
    }

    # copy stash
    my $current_form  = $self->current_form;
    my $current_stash = $current_form->stash;

    for my $key ( keys %$current_stash ) {
        $next_form->stash->{$key} = $current_stash->{$key};
    }

    # persist_stash
    for my $key ( @{ $self->persist_stash } ) {
        $next_form->stash->{$key} = $current_form->stash->{$key};
    }

    # build the form
    $next_form->populate($form_data);
    
    # add hidden field
    if ( !defined $self->multiform_hidden_name ) {
        my $field = $next_form->element({
            type => 'Hidden',
            name => $self->default_multiform_hidden_name,
        });
        
        $field->constraint({
            type => 'Required',
        });
    }

    $next_form->query( $self->query );
    $next_form->process;

    # encrypt params in hidden field
    $self->_save_hidden_data( $current_form_num, $next_form, $form );

    return $next_form;
}

sub _save_hidden_data {
    my ( $self, $current_form_num, $next_form, $form ) = @_;

    my @valid_names = $form->valid;
    my $hidden_name = $self->multiform_hidden_name;
    
    $hidden_name = $self->default_multiform_hidden_name
        if !defined $hidden_name;

    # don't include the hidden-field's name in valid_names
    @valid_names = grep { $_ ne $hidden_name } @valid_names;

    my %params;
    my @file_fields = @{ $self->_file_fields || [] };

    for my $name (@valid_names) {
        my $value = $form->param_value($name);

        $self->set_nested_hash_value( \%params, $name, $value );

        # populate @file_field
        $value = [$value] if ref $value ne 'ARRAY';

        for my $value (@$value) {
            if ( blessed($value) && $value->isa('HTML::FormFu::Upload') ) {
                push @file_fields, $name;
                last;
            }
        }
    }

    @file_fields = sort uniq(@file_fields);

    my $crypt = Crypt::CBC->new( %{ $self->crypt_args } );

    my $data = {
        current_form  => $current_form_num + 1,
        valid_names   => \@valid_names,
        params        => \%params,
        persist_stash => {},
        file_fields   => \@file_fields,
    };

    # persist_stash
    for my $key ( @{ $self->persist_stash } ) {
        $data->{persist_stash}{$key} = $form->stash->{$key};
    }

    # save file_fields
    $self->_file_fields(\@file_fields);

    # to freeze, we need to remove any file handles in the form
    # make sure we restore them, after freezing
    my $current_form = $self->current_form;

    my $input            = $current_form->input;
    my $query            = $current_form->query;
    my $processed_params = $current_form->_processed_params;
    
    $current_form->input({});
    $current_form->query({});
    $current_form->_processed_params({});

    # freeze
    local $Storable::canonicle = 1;
    $data = nfreeze($data);

    # store data in hidden field
    $data = $crypt->encrypt_hex($data);

    my $hidden_field
        = $next_form->get_field( { nested_name => $hidden_name, } );

    $hidden_field->default($data);

    # restore form file handles
    $current_form->input($input);
    $current_form->query($query);
    $current_form->_processed_params($processed_params);

    return;
}

1;

__END__

=head1 NAME

HTML::FormFu::MultiForm

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
