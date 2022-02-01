#!/usr/bin/env perl
use strict;
use warnings;
use autodie;
use 1.000;
use open qw( :std :encoding(utf8) );
use Config::INI::Reader;
use Data::Dumper;
require Server;
require Downloader;

my $config;

if (-e 'config.ini') {
    $config = Config::INI::Reader->read_file('config.ini');
} else {
    $config = Config::INI::Reader->read_file('default-config.ini');
}

my $server = Server->new;

$server->config($config);

$server->connection;

my $dwld = Downloader->new;

$dwld->init($config, $server);

$dwld->download($server);

print "\n";
