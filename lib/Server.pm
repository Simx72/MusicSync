package Server;

use Moose;
use namespace::autoclean;
use open qw( :std :encoding(utf8) );
use HTTP::Request;
use LWP::UserAgent;

has 'host' => ( is => 'rw', isa => 'Str', default => 'localhost' );
has 'port' => ( is => 'rw', isa => 'Str', default => '80' );
has 'path' => ( is => 'rw', isa => 'Str', default => '/' );
has 'resp' => ( is => 'rw', isa => 'Str', default => '' );

sub config {
    my $self = shift;
    my ($config) = @_;

    $self->host( $config->{'music_server'}{'host'} );
    $self->port( $config->{'music_server'}{'port'} );
    $self->path( $config->{'music_server'}{'path'} =~ s/^\///r );

    return 1;
}

sub url {
    my $self = shift;
    return "http://". $self->host .":". $self->port ."/". $self->path;
}

sub connection {
    my $self = shift;

    my $url = $self->url;

    print "Connecting to server URL:\n  $url\n\n";

    my $request = HTTP::Request->new( GET => $url );

    my $ua = LWP::UserAgent->new;

    my $response = $ua->request($request);

    if ( $response->is_success ) {
        my $message = $response->decoded_content;

        print "Received reply from server\n";
        #print "$message";

        $self->resp($message);

    }
    else {
        print "HTTP GET error code: ",    $response->code,    "n";
        print "HTTP GET error message: ", $response->message, "n";
    }

}

1;
