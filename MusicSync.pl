#!/usr/bin/env perl
use strict;
use warnings;
use autodie;
use 1.000;
use open qw( :std :encoding(utf8) );
use Config::INI::Reader;
use Data::Dumper;
use lib qx/pwd/."/lib"
require ConfigLoader;
require Server;
require Downloader;

my $configloader = ConfigLoader->new;

my $config;

$configloader->getconfig($config);


print Dumper(\$config);
exit 1;

my $server = Server->new;

$server->config($config);

$server->connection;

my $dwld = Downloader->new;

$dwld->init( $config, $server );

if ( $config->{'test'}{'download'} != "0" ) {
    $dwld->download($server);
}

print "\n";
