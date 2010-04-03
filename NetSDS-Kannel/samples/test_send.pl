#!/usr/bin/env perl 
use 5.8.0;
use strict;
use warnings;

use Data::Dumper;
use NetSDS::Kannel;
use NetSDS::Message::SMS;

my $k = NetSDS::Kannel->new(
	sendsms_url    => 'http://127.0.0.1:13013/cgi-bin/sendsms',
	sendsms_user   => 'tester',
	sendsms_passwd => 'foobar',
	admin_passwd   => 'bar',
);

my $m = NetSDS::Message::SMS->new(
	from => '3333@smsc.nokia',
	to   => '380672206770@smsc.nokia',
);

#print "R: " . $k->suspend() . " : " . $k->errstr;
print "\n=================================\n\n";
print "R: " . Dumper($k->status());

exit 1;
__END__
my $res = $k->send(
#	message => $m,
	from => '12345',
	to   => '+380672206770',
	smsc => 'FAKE',
	text => 'Hallo :)',
);


if ($res) {
	print "RES: $res\n";
}	else {
	print "ERR: " . $k->errstr . "\n";
}

1;
