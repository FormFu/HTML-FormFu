package unicode::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller::HTML::FormFu';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

unicode::Controller::Root - Root Controller for unicode

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut

sub default : Private {
    my ( $self, $c ) = @_;

    $c->response->body( <<HTML );
<html>
<body>
<a href="/tt">TT</a><br />
<a href="tt_alloy">Template::Alloy</a>
</body>
HTML
}

sub tt : Local : FormConfig('index.yml') {
    my ( $self, $c ) = @_;
    
    $c->stash->{template} = 'index.tt';
    
    $c->forward('View::TT');
}

sub tt_alloy : Local : FormConfig('index.yml') {
    my ( $self, $c ) = @_;
    
    $c->stash->{form}->render_class_args->{TEMPLATE_ALLOY} = 1;
    $c->stash->{form}->render_class_args->{ENCODING} = 'utf8';
    
    $c->stash->{template} = 'index.tt';
    
    $c->forward('View::TT::Alloy');
}

=head1 AUTHOR

Carl Franks

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
