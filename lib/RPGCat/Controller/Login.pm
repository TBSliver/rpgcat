package RPGCat::Controller::Login;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

RPGCat::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub login_index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $email = $c->request->param('email');
    my $password = $c->request->param('password');

    if ($email && $password) {

        # Default location after login
        $c->response->redirect("/");

        # Attempt to log the user in
        if ($c->authenticate({
                email => $email,
                password => $password
            })) {

            # Prevents session fixation exploit
            $c->change_session_id;

            my $ral = $c->flash->{ redirect_after_login };
            if ($ral) {
                $c->response->redirect($ral);
            }
        } else {

            # Set an error
            $c->response->redirect(
                $c->uri_for(
                    $c->controller('Login')->action_for('login_index'), {
                        mid => $c->set_error_msg("Bad email or password")
                    }
                )
            );
            $c->detach();
        }
    }

    $c->stash(
        template => "login.html"
    );
}



=encoding utf8

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
