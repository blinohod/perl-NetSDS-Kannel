#!/usr/bin/env perl

use warnings;
use strict;

KannelSend->run( daemon => 0, use_pidfile => 0,
	conf_file => '/home/yana/kannel/perl-NetSDS-Kannel/NetSDS-Kannel/conf/kannel_send.conf');

package KannelSend;

use FindBin qw/$Bin/;
use lib ("$Bin/../lib", 
	"/home/yana/admin/NetSDS-Admin/NetSDS-Admin/lib");

use base 'NetSDS::App';

use NetSDS::Const::Message;
use NetSDS::Kannel;
use NetSDS::Message::SMS;
use NetSDS::DBI;
use NetSDS::Queue;

use Data::Dumper;

sub start {
	my $self = shift;
	
	$self->{'dbh'} = NetSDS::DBI->new(
		%{ $self->conf->{'db'} }
	);

	$self->{'queue'} = NetSDS::Queue->new( 
		server => $self->conf->{'queue_server'} 
	);

	$self->{'kannel'} = NetSDS::Kannel->new( 
		%{ $self->conf->{'kannel'} } 
	); 

	$self->{'channel'} = $self->conf->{'channel_id'};
	return $self;
};

sub accounts {
	my $self = shift;
	my $users = $self->{'dbh'}->dbh->selectcol_arrayref("
		select uuid from auth.users where active=true");

	return $self->{'dbh'}->dbh->selectall_arrayref(sprintf(
		"select id, owner, bandwidth from bulksms.accounts 
			where owner in ('%s') and current_time between mt_start and mt_finish", 
		join "','", @$users), { Slice => {} });
};

sub process {
	my $self = shift;
	my %accounts = map { ($_->{'owner'} => { bandwith => $_->{'bandwidth'}, 
		time => +time, id => $_->{'id'} } ) } @{ $self->accounts };
	
	my ($keeprun, $start) = (1, time);
	while ($keeprun) {
		my @array = grep { $accounts{$_}->{'time'} <= time } keys %accounts;
		sleep($self->conf->{'account_wait'}) and next unless @array;

		for my $acct_id ( @array ) {
			my $queue = join '.', 'mt', $accounts{$acct_id}->{'id'}, $self->{'channel'};
			for (1..$accounts{$acct_id}->{'bandwith'}) {
				my $sms = $self->{'queue'}->pull($queue);
				
				if ($sms) {
					my $keep = 1;
					do {
						unless($self->send($sms)) {
							if ($self->{'kannel'}->errstr =~ /^4\d{2}\s+/) {
								$self->{'dbh'}->call("select bulksms.discard_charge('$acct_id', 1)");
								$keep = 0;
							};
						} else {
							$self->{'dbh'}->call("select bulksms.accept_charge('$acct_id', 1)");
							$keep = 0;
						};

					} while ($keep);
				} else {
					$accounts{$acct_id}->{'time'} = 
						time + $self->conf->{'account_wait'};

					last;
				};
			};
		};
		
		$keeprun = 0 if $start + $self->conf->{'period'} > time;
	};
};

sub send {
	my ($self, $msg) = @_;
	bless $msg, 'NetSDS::Message::SMS';
	    
	my %mt_msg = (
		smsc     => $self->conf->{'smsc'},    # Kannel SMSC Id
		from     => $msg->src_addr_native,    # source address (may be alphanumeric)
		to       => $msg->dst_addr_native,    # destination address (usually MSISDN)
		coding   => $msg->coding,             # SMS coding (0 - GSM 03.38 7bit, 1 - binary, 2 - UCS2)
		text     => $msg->ud,                 # User data as byte string
		udh      => $msg->udh,                # User Data Header as byte string
		#dlr_mask => 3,                        # only final states
		charset  => ( $msg->coding == COD_UCS2 ? 'UTF-8' : 'UTF-16BE' ),                  
		priority => 0,                        # Default is non priority SMS
		#dlr_id   => $msg->message_id,
	);
	
	$mt_msg{'mclass'} = $msg->mclass if  defined $msg->mclass;
	return $self->{'kannel'}->send(%mt_msg);
};

sub stop {
	my $self = shift;
	$self->{'dbh'}->dbh->disconnect;
	return $self;
};

1;
