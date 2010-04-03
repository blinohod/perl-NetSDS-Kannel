#!/usr/bin/env perl 

use 5.8.0;
use warnings;
use strict;

Kanneladm->run(
	conf_file => '/home/misha/git/NetSDS/perl-NetSDS-Kannel/NetSDS-Kannel/conf/kanneladm-service.conf',
	debug     => 1,
);

1;

package Kanneladm;

use lib '/home/misha/git/NetSDS/perl-NetSDS-Kannel/NetSDS-Kannel/lib';

use NetSDS::Kannel;
use NetSDS::Message::SMS;

use Data::Dumper;

use base 'NetSDS::App::GUI';

sub start {
	my $self = shift;

	$self->{'kannel'} = NetSDS::Kannel->new( %{ $self->conf->{'kannel'} } );

	return $self;
}

sub act_status {

	my $self = shift;

	# Retrieve Kannel status via HTTP XML API
	my $gw_info = $self->{'kannel'}->status();

	return {
		version             => $gw_info->{version},                   # Version string
		status              => $gw_info->{status},                    # Whole Kannel status
		uptime              => $gw_info->{uptime},                    # Kannel uptime
		sms_sent_total      => $gw_info->{sms}->{sent_total},         # Total MT SM
		sms_sent_queued     => $gw_info->{sms}->{sent_queued},        # Queued MT SM
		sms_received_total  => $gw_info->{sms}->{received_total},     # Total MO SM
		sms_received_queued => $gw_info->{sms}->{received_queued},    # Queued MO SM
		sms_inbound         => $gw_info->{sms}->{inbound},            # Inbound bandwidth
		sms_outbound        => $gw_info->{sms}->{outbound},           # Outbound bandwidth
		dlr_storage         => $gw_info->{dlr}->{storage},            # DLR storage type (internal, mysql, etc)
		dlr_queued          => $gw_info->{dlr}->{queued},             # Queued DLR
		smsc                => $gw_info->{smsc},                      # SMSC info
	};

} ## end sub act_status

sub act_stop_smsc {
	my ($self) = @_;

	$self->{kannel}->stop_smsc( $self->call_param('smsc') );
	return "Stopped SMSC: " . $self->call_param('smsc');

}

sub act_start_smsc {
	my ($self) = @_;

	$self->{kannel}->start_smsc( $self->call_param('smsc') );
	return "Started SMSC: " . $self->call_param('smsc');

}

sub act_send_sms {
	my $self = shift;
	my @smsc = map { { key => $_->{'id'} } } @{ $self->{'kannel'}->request('status') };

	return { smsc => \@smsc };
}

sub act_send_msg {
	my $self = shift;
	my $msg  = NetSDS::Message::SMS->new( map { ( $_ => $self->call_param($_) ) } qw/from to/ );

	my $res = $self->{'sender'}->send(
		map { ( $_ => $self->call_param($_) ) } qw/from to smsc text/,
		message => $msg
	);

	return { res => $res ? $res : $self->{'sender'}->errstr };
}

1;
