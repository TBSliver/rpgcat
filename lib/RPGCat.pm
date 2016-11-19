package RPGCat;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Static::Simple

    Authentication
    Authorization::Roles

    Session
    Session::Store::DBI
    Session::State::Cookie

    StatusMessage
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in rpgcat.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'RPGCat',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
);

# Authentication
__PACKAGE__->config(
    'Plugin::Authentication' => {
        default => {
            store => {
                class           => 'DBIx::Class',
                user_model      => 'DB::Account',
                role_relation   => 'roles',
                role_field      => 'role',
                use_userdata_from_session   => 0, # cache user data in session
            },
            credential => {
                class           => 'Password',
                password_type   => 'self_check',
            },
        },
    },
);

# Default view for pages
__PACKAGE__->config(
    default_view => 'Web',

    'Plugin::Session' => {
        dbi_dbh   => 'DB', # which means RPGCat::Model::DB
        dbi_table => 'sessions',
        dbi_id_field => 'id',
        dbi_data_field => 'session_data',
        dbi_expires_field => 'expires',

        expires   => 3600*72,   # 72 hours (in seconds)

        # If nothing in the session changed, only refresh the expiry
        # time if it's got less than 70 hours until it expires
        expiry_threshold => 3600*70,
    },
);


# Start the application
__PACKAGE__->setup();


=encoding utf8

=head1 NAME

RPGCat - Catalyst based application

=head1 SYNOPSIS

    script/rpgcat_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<RPGCat::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;