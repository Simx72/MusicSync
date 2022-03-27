package ConfigLoader;

use Moose;
use namespace::autoclean;

sub getconfig {
    my ($out) = @_;

    my $default_hash = Config::INI::Reader->read_file('default-config.ini');

    if ( -e 'config.ini' ) {
        $out = Config::INI::Reader->read_file('config.ini');

        for ( keys %$default_hash ) {
            print "$_\n";
            my %option        = $default_hash->{$_};
            my %config_option = $out->{$_};
            @option{ keys %option } = @config_option{ keys %option };
            $default_hash->{$_} = $option{$_};
        }

    }
    else {
        $out = \ %$default_hash;
    }

    $out;
}

1;
