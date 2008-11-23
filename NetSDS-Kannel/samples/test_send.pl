#!/usr/bin/env perl 
use 5.8.0;
use strict;
use warnings;

use NetSDS::Kannel;
use NetSDS::Message::SMS;

my $k = NetSDS::Kannel->new(
	sendsms_url    => 'http://127.0.0.1:13013/cgi-bin/sendsms',
	sendsms_user   => 'tester',
	sendsms_passwd => 'foobar',
);

my $m = NetSDS::Message::SMS->new(
	from => '3333@smsc.nokia',
	to   => '380672206770@smsc.nokia',
);

my $res = $k->send(
	message => $m,
	from => '12345',
#	to   => '+380672206770',
	smsc => 'FAKE',
	text => 'Hallo :)',
);


if ($res) {
	print "RES: $res\n";
}	else {
	print "ERR: " . $k->errstr . "\n";
}

1;
