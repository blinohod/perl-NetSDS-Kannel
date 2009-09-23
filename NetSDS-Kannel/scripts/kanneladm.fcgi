#!/usr/bin/perl 

use strict;
use warnings;

Kanneladm->run( conf_file => 'kanneladm-service.conf' );

1;

package Kanneladm;

use lib qw( /home/yana/NetSDS/NetSDS-ContactDB/lib
	/home/yana/admin/NetSDS-Admin/NetSDS-Admin/lib
	/home/yana/kannel/perl-NetSDS-Kannel/NetSDS-Kannel/lib);

use NetSDS::Kannel::Admin;
use Data::Dumper;

use base 'NetSDS::App::GUI';

sub start {
	my $self = shift;
	
	$self->{'kannel'} = NetSDS::Kannel::Admin->new(
		url => $self->conf->{'url'}
	);

	return $self;
};

sub act_status {
	my $self = shift;
	my $data = $self->{'kannel'}->get_structure('status');
	
	my $res = []; 
	_data($_, $res, 1) for @$data;
	
	return { param => $res };
};

sub _data { 
	my ($struct, $r, $level) = @_;
	
	for my $item (keys %$struct) {
		my $result;
		
		if (ref $struct->{$item}) {
			my $temp = [];

			_data($_, $temp, $level + 1) for @{ $struct->{$item} };
			$result = { key => $item, ('param' . $level) => $temp };

		} else {

			$result = { key => $item, val => $struct->{$item} };
		};

		push @$r, $result;
	};
};

1;
