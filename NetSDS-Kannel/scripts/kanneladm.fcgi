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

sub act_list {
	my $self = shift;
	my $data = $self->{'kannel'}->request('status');
	
	my $params = { smsc => [] };
	for my $item (@$data) {
		my $res = [];
		_data($item, $res, 1);

		my ($dead, $id) = (0, 0);
		my $check = 0;

		for my $h (@$res) {
			if ($h->{'key'} eq 'status') {
				$dead = 1 if $h->{'val'} eq 'dead';
				$check++;
			
			} elsif ($h->{'key'} eq 'id') {
				$id = $h->{'val'} and $check++;
			};
			
			last if $check == 2;
		};
		
		push @{ $params->{'smsc'} }, { param2 => $res, 
			dead => $dead, id => $id };
	};

	return { %$params, reload => $self->call_param('reload') || 0 };
};

sub act_do_action {
	my $self = shift;
	my ($action, $id) = map { $self->call_param($_) } qw/str id/;

	if ($action eq 'restart') {
		$self->{'kannel'}->action('stop-smsc', $self->conf->{'pass'}, $id);
		
		sleep(1);
		$action = 'start-smsc';
	};

	return { res => $self->{'kannel'}->action($action, 
			$self->conf->{'pass'}, $id) };
}

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
