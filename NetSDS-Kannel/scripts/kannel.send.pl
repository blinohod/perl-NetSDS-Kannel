#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  kannel.send
#
#        USAGE:  ./kannel.send
#
#  DESCRIPTION:  Outgoing queue processor
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Michael Bochkaryov (Rattler), <misha@rattler.kiev.ua>
#      COMPANY:  Net.Style
#      CREATED:  12.09.2009 20:18:19 EEST
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use lib '../lib';

KannelSender->run(
	has_conf => 1,
	verbose  => 1,
	edr_file => './kannel.send.edr',
);

1;

package KannelSender;

use base 'NetSDS::App::QueueProcessor';

use NetSDS::Kannel;            # Kannel SMS gateway API
use NetSDS::Message::SMS;      # SMS struture class
use NetSDS::Util::DateTime;    # Date and time processing
use NetSDS::Const::Message;

use Data::Dumper;

sub start {

	my ($self) = @_;

	$self->mk_accessors('kannel');
	$self->kannel( NetSDS::Kannel->new( %{ $self->conf->{'kannel'} } ) );

}

sub process {

	my ( $self, $msg ) = @_;
	bless $msg, 'NetSDS::Message::SMS';

	# Prepare default message
	my %mt_msg = (
		smsc     => $self->conf->{'smsc'},    # Kannel SMSC Id
		from     => $msg->src_addr_native,    # source address (may be alphanumeric)
		to       => $msg->dst_addr_native,    # destination address (usually MSISDN)
		coding   => $msg->coding,             # SMS coding (0 - GSM 03.38 7bit, 1 - binary, 2 - UCS2)
		text     => $msg->ud,                 # User data as byte string
		udh      => $msg->udh,                # User Data Header as byte string
		dlr_mask => 3,                        # only final states
		charset  => 'UTF-8',                  #
		priority => 0,                        # Default is non priority SMS
		dlr_id   => $msg->message_id,
	);

	# Change SMS charset
	if ( $msg->coding == COD_UCS2 ) {
		$mt_msg{charset} = 'UTF-16BE';
	} elsif ( $msg->coding == COD_BINARY ) {
		delete $mt_msg{charset};
	}

	# Process message class if exists
	if ( defined $msg->mclass ) {
		$mt_msg{mclass} = $msg->mclass;
	}
	#if (defined $msg->validity) {
	#}

	# Sending messages to SMS gateway
	my $retry_left  = $self->conf->{resend_retry};
	my $send_status = undef;

	while ( $retry_left > 0 ) {

		$retry_left--;

		my $res = undef;
		# Try to send SM via HTTP API
		eval { $res = $self->kannel->send(%mt_msg); };

		# Check result message
		if ($res) {
			$self->log( "info", "MT SM accepted by Kannel: id=" . $msg->message_id );
			$self->speak("MT SM accepted by Kannel: $res");
			$retry_left  = 0;
			$send_status = "accepted";
		} else {
			my $err_status = $self->kannel->errstr;
			$self->speak("MT SM finally rejected by Kannel: $err_status");

			# Kannel API provides the following error responses
			# 4xx - fatal error, message cant be delivered in any case
			# 503 - temporal failure, try again later
			if ( $err_status =~ /^4\d\d\s+/ ) {
				$self->log( "error", "MT SM rejected by Kannel: id=" . $msg->message_id );
				$retry_left  = 0;
				$send_status = "rejected";
			} elsif ( $err_status =~ /^50\d\s+/ ) {
				$self->log( "warning", "Temporary error when submit MT SM: id=" . $msg->message_id );
				sleep $self->conf->{resend_timeout};    # sleep few seconds to avoid system overloading
				$send_status = "rejected";              # set 'rejected' status at the moment
			}
		}
	} ## end while ( $retry_left > 0 )

	# Write EDR record
	$self->edr(
		{
			smsc       => $mt_msg{smsc},
			message_id => $msg->message_id,
			status     => $send_status,
			src_addr   => $msg->src_addr_native,
			dst_addr   => $msg->dst_addr_native,
			timestamp  => date_now,
		}
	);

} ## end sub process

1;
#===============================================================================

__END__

=head1 NAME

kannel.send.pl

=head1 SYNOPSIS

kannel.send.pl

=head1 DESCRIPTION

FIXME

=head1 EXAMPLES

FIXME

=head1 BUGS

Unknown.

=head1 TODO

Empty.

=head1 AUTHOR

Michael Bochkaryov <misha@rattler.kiev.ua>

=cut

