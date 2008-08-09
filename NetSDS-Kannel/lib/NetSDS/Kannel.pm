#===============================================================================
#
#         FILE:  Kannel.pm
#
#  DESCRIPTION:  This module provides API to Kannel message structure.
#
#        NOTES:  This is NetSDS specific implementation
#       AUTHOR:  Michael Bochkaryov (Rattler), <misha@rattler.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  16.06.2008 11:08:15 EEST
#     REVISION:  $Id: Kannel.pm 40 2008-06-23 07:12:35Z misha $
#===============================================================================

=head1 NAME

NetSDS::Message::Kannel

=head1 SYNOPSIS

	use NetSDS::Message::Kannel;

=head1 DESCRIPTION

C<NetSDS> module contains superclass all other classes should be inherited from.

=cut

package NetSDS::Message::Kannel;

use 5.8.0;
use strict;
use warnings;

use NetSDS::Util::Text qw(text_recode);

use base qw(NetSDS::Message);

our $VERSION = "1.0";

our @EXPORT_OK = qw(
  COD_7BIT
  COD_8BIT
  COD_UCS2
);

# Message encoding
use constant COD_7BIT => '0';
use constant COD_8BIT => '1';
use constant COD_UCS2 => '2';

use constant DLR_UNDELIVERABLE => 'UNDELIV';

#===============================================================================
#

=head1 CLASS METHODS

=over

=item B<new([...])>

Common constructor for all objects inherited from Wono.

    my $object = Wono::SomeClass->new(%options);

=cut

#-----------------------------------------------------------------------
sub new {

	my ( $class, %params ) = @_;

	my $this = $class->SUPER::new(
		content => {
			udh  => undef,
			body => '',
		},
		media   => 'sms',
		coding  => COD_7BIT,
		charset => 'WINDOWS-1252',
		meta    => {},
		smsc    => undef,

	);

	return $this;

} ## end sub new

#***********************************************************************

=head1 OBJECT METHODS

=over

=item B<import_cgi($cgi)> - import message from CGI object

This method provides import message structure from CGI request.

=cut

#-----------------------------------------------------------------------

sub import_cgi {

	my ( $this, $cgi ) = @_;

	# Set message type (MO or DLR)
	if ( $cgi->param('type') and ( $cgi->param('type') =~ /^(mo|dlr)$/ ) ) {
		$this->type( $cgi->param('type') );
	} else {
		$this->type('mo');
	}

	# Set message Id
	if ( $cgi->param('msgid') ) {
		$this->msgid( $cgi->param('msgid') );
	} else {
		$this->msgid(undef);
	}

	# Set source (subscriber) address
	if ( $cgi->param('from') ) {
		$this->from( $cgi->param('from') );
	}

	# Set destination (service) address
	if ( $cgi->param('to') ) {
		$this->to( $cgi->param('to') );
	}

	# Set timestamp information
	if ( $cgi->param('timestamp') ) {
		$this->timestamp( $cgi->param('timestamp') );
	}

	# Set billing information
	if ( $cgi->param('binfo') ) {
		$this->binfo( $cgi->param('binfo') );
	}

	# Process optional SMPP TLV
	if ( $cgi->param('meta') ) {
		my $meta_str = $cgi->param('meta');
		my %meta     = ();
		if ( $meta_str =~ /^\?smpp\?(.*)$/ ) {
			foreach my $tlv_par ( split /\&/, $1 ) {
				my ( $tag, $val ) = split /\=/, $tlv_par;
				$this->{meta}->{$tag} = $val;
			}
		}
	}

	# Process message type specific information

	if ( $this->type eq 'mo' ) {

		# Process MO SM
		my $charset = $cgi->param('charset');
		my $coding  = $cgi->param('coding');
		my $text    = $cgi->param('text');
		my $udh     = $cgi->param('udh');
		my $bindata = $cgi->param('bindata');

		if ( $coding ne COD_8BIT ) {
			# It's text message
			text_recode( $text, $charset );
			$this->{content}->{body} = $text;

		} else {
			# It's binary message
			$this->{content}->{udh}  = $udh;
			$this->{content}->{body} = $bindata;
		}

		# Set user data headers
		if ($udh) {
			$this->{content}->{udh} = $udh;
		}

	} elsif ( $this->type eq 'dlr' ) {
		# Process DLR

		my $ref_id   = $cgi->param('refid');
		my $dlr_code = $cgi->param('dlr');
		my $dlr_msg  = $cgi->param('dlrmsg');

		if ($dlr_code) {
			$this->{dlr_code} = $dlr_code;
		}

		if ($dlr_msg) {
			$this->{dlr_msg} = $dlr_msg;
		}
	}

} ## end sub import_cgi

1;

__END__

=back

=head1 EXAMPLES


=head1 BUGS

Unknown yet

=head1 SEE ALSO

None

=head1 TODO

None

=head1 AUTHOR

Michael Bochkaryov <misha@rattler.kiev.ua>

=cut


