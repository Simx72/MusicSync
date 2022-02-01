package Downloader;

use Moose;
use namespace::autoclean;
use open qw( :std :encoding(utf8) );
use JSON;
#use Data::Dumper;
use URI::Encode;

has 'verify' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'download_folder' => ( is => 'rw', isa => 'Str', default => '~/Downloads' );
has 'missing' => ( is => 'rw', isa => 'Maybe[ArrayRef[Any]]' );

sub init {
    my $self = shift;
    my ( $config, $server ) = @_;
    
    $self->download_folder( $config->{'local'}{'download_folder'} );

    print "Checking valid reply from server...\n";
    if ( $server->resp ne '' ) {

        my @music_folders = split( /,/, $config->{'local'}{'music_folders'} );

        my $server_res = from_json( $server->resp );

        my $result = $server_res->{'result'};

        print "Reply verified\n\nSearching missing songs in device...\n";

        my @missing = ();

        for (@$result) {
            my $fichero = $_;

            if ( $fichero->{'type'} eq 'file' ) {

                my $song = $fichero->{'name'};
                my $url = $fichero->{'path'} =~ s/^\/storage/file/r;

                if ( $self->is_song( \@music_folders, $song ) == 0 && $song =~ m/^[^\.]/ ) {
                    
                    my %hash = (
                        'name' => $song,
                        'url' => $url 
                    );
                    
                    push @missing, \%hash;
                    print "- $song\n";
                }

            }

        }

        $self->missing(\@missing);

    }
}

sub is_song {
    my ( $self, $folders, $song ) = @_;

    $song =~ s/"/\\"/g;

    #print $song;

    for (@$folders) {
        my $res = qx(ls $_);
        if ( index( $res, $song ) >= 0 ) {
            return 1;
        }
    }

    return 0;
}

sub download {
    my ($self, $server) = @_;

    my $missing = $self->missing;

    my $check = @$missing;

    if ($check) {
            
        print "Downloading songs...\n";

        for (@$missing) {

            my $songref = $_;
            my $uri = URI::Encode->new;
            
            my $song = $songref->{'name'} =~ s/"/\\"/gr;
            my $url_path = $songref->{'url'};
            my $url_host = $server->host;
            my $url_port = $server->port;
            my $download_folder = $self->download_folder =~ s/"/\\"/gr;

            my $url = $uri->encode("http://$url_host:$url_port/$url_path");

            #print "Downloading: $url\n";
            print "Downloading: $song\n";

            my $sh = qq(curl "$url" --output "$download_folder/$song");

            #print "script: $sh\n";

            my $res = qx($sh --silent);
            
        }

    }

}

1;
