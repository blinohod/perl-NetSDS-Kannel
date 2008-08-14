#===============================================================================
#
#         FILE:  Kannel.pm
#
#  DESCRIPTION:  This module provides API to Kannel message structure.
#
#        NOTES:  This is NetSDS specific implementation
#       AUTHOR:  Michael Bochkaryov (Rattler), <misha@rattler.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.1
#      CREATED:  16.06.2008 11:08:15 EEST
#===============================================================================

=head1 NAME

NetSDS::Kannel - Kannel SMS gateway API

=head1 SYNOPSIS

	use NetSDS::Kannel;
	use NetSDS::Message::SMS;

	my $kannel = NetSDS::Kannel->new(
		kannel_url => 'http://localhost:1234/sendsms',
		kannel_user => 'sender',
		kannel_passwd => 'secret',
		default_smsc => 'esme-megafon',
	);

	my $sms = NetSDS::Message::SMS->new(
		$sms_params
	);

	$res = $kannel->send(
		message => $sms,
		smsc => 'emse-mts',
		priority => 3,
	);

=head1 DESCRIPTION

C<NetSDS::Kannel> module provides API to Kannel SMS gateway.

To decrease innecessary problems we use a lot of predefined parameters
while sending and receiving messages via Kannel HTTP API. It's not so flexible
as direct HTTP processing but less expensive in development time ;-)

This modules uses LWP to send messages and CGI.pm to process messages from Kannel.

=cut

package NetSDS::Kannel;

use 5.8.0;
use strict;
use warnings;

use NetSDS::Util::Text qw(text_recode);
use NetSDS::Messaging::Const;
use NetSDS::Message::SMS;
use LWP::UserAgent;
use URI::Escape;

use base qw(NetSDS::Class::Abstract);

our $VERSION = "1.1";

use constant USER_AGENT => 'NetSDS Kannel API';

#===============================================================================
#

=head1 CLASS METHODS

=over

=item B<new([...])> - constructor

Constructor creates Kannel API handler and set configuration for it.

Parameters:

* sendsms_url

* sendsms_user

* sendsms_passwd

* dlr_url

* default_smsc

* default_timeout

=cut

#-----------------------------------------------------------------------
sub new {

	my ( $class, %params ) = @_;

	my $this = $class->SUPER::new(
		admin_url       => 'http://127.0.0.1:1300/',
		admin_user      => 'admin',
		admin_passwd    => '',
		sendsms_url     => 'http://127.0.0.1:13013/cgi-bin/sendsms',
		sendsms_user    => 'netsds',
		sendsms_passwd  => '',
		dlr_url         => 'http://127.0.0.1/smsc/kannel_receiver.fcgi',
		default_smsc    => undef,
		default_timeout => 30,                                             # 30 seconds enough for sending timeout
		%params,
	);

	return $this;

} ## end sub new

__PACKAGE__->mk_accessors('admin_url');
__PACKAGE__->mk_accessors('admin_user');
__PACKAGE__->mk_accessors('admin_passwd');
__PACKAGE__->mk_accessors('sendsms_url');
__PACKAGE__->mk_accessors('sendsms_user');
__PACKAGE__->mk_accessors('sendsms_passwd');
__PACKAGE__->mk_accessors('dlr_url');
__PACKAGE__->mk_accessors('default_smsc');
__PACKAGE__->mk_accessors('default_timeout');

#***********************************************************************

=head1 OBJECT METHODS

=over

=item send(%parameters) - send message to Kannel

This method allows to send SMS message via Kannel SMS gateway.

Parameters:

* message - NetSDS::Message::SMS object

* from - source address (overrides message)

* to - destination address (overrides message)

* smsc - target SMSC (overrides default one)

	$kannel->send_sms(
		from => '1234',
		to => '380672206770',
		text => 'Wake up!!!',
		smsc => 'nokia_modem',
	);

=cut

#-----------------------------------------------------------------------

sub send {

	my ( $this, %params ) = @_;

	my %send = (
		username => $this->sendsms_user,
		password => $this->sendsms_passwd,
	);

	# First try to parse SMS message
	if ( $params{message} and ( ref $params{message} eq 'NetSDS::Message::SMS' ) ) {

		my $msg = $params{message};

		if ( $msg->from ) {
			$send{from} = uri_escape( $msg->from_native );
		}

		if ( $msg->to ) {
			$send{to} = uri_escape( '+' . $msg->to_native );
		}

		if ( $msg->udh ) {
			$send{udh} = uri_escape( $msg->udh );
		}

		if ( $msg->ud ) {
			$send{text} = uri_escape( $msg->ud );
		}

	} ## end if ( $params{message} ...

	# Then we override message parameters

	# Set sendsms URL
	my $send_url = $this->sendsms_url;
	if ( $params{sendsms_url} ) {
		$send_url = $params{sendsms_url};
	}

	# Set sendsms username
	if ( $params{sendsms_user} ) {
		$send{username} = $params{sendsms_user};
	}

	# Set sendsms password
	if ( $params{sendsms_passwd} ) {
		$send{password} = $params{sendsms_passwd};
	}

	# Set source address
	if ( $params{from} ) {
		$send{from} = uri_escape( $params{from} );
	}

	# Set destination address
	if ( $params{to} ) {
		$send{to} = uri_escape( $params{to} );
	}

	# Set message text
	if ( $params{text} ) {
		$send{text} = uri_escape( $params{text} );
	}

	# Prepare sending user agent
	my $ua = LWP::UserAgent->new();
	$ua->agent( USER_AGENT . "/$VERSION" );

	# Set HTTP timeout
	my $timeout = $this->default_timeout;
	if ( $params{timeout} ) {
		$timeout = $params{timeout};
	}
	$ua->timeout($timeout);

	# Prepare HTTP request
	my @pairs = map $_ . '=' . $send{$_}, keys %send;
	my $req = HTTP::Request->new( GET => $send_url . "?" . join '&', @pairs );

	my $res = $ua->request($req);

	if ( $res->is_success ) {
		return $res->content;
	} else {
		return $this->error( $res->status_line );
	}

} ## end sub send

#***********************************************************************

=item B <receive($cgi)> - import message from CGI object

  This method provides import message structure from CGI request .

=cut

#-----------------------------------------------------------------------

sub receive {

	my ( $this, $cgi ) = @_;

	my $msg = NetSDS::Message::SMS->new();

	# Set message type (MO or DLR)
	if ( $cgi->param('type') and ( $cgi->param('type') =~ / ^ ( mo | dlr ) $/ ) ) {
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

} ## end sub receive

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

