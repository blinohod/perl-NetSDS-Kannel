package NetSDS::Kannel::Admin;

use strict;
use warnings;

use LWP::UserAgent;
use XML::LibXML;

use base qw(NetSDS::Class::Abstract);

sub _get_action {
	my %subst = (
		'status'       => 'request',
		'stop-smsc'    => 'action',
		'start-smsc'   => 'action',
		'restart'      => 'action',
		'suspend'      => 'action',
		'isolate'      => 'action',
		'resume'       => 'action',
		'flush-dlr'    => 'action',
		'shutdown'     => 'action',
		'reload-lists' => 'action',
		'log-level'    => 'action'
	);

	return $subst{ +shift };
}

sub request {
	my ( $self, $url ) = @_;

	my ( $parser, $res ) = ( XML::LibXML->new, [] );
	my $response = LWP::UserAgent->new->get( $url . ".xml" );

	if ( $response->is_success ) {
		my $doc = $parser->parse_string( $response->decoded_content );

		for my $node ( $doc->getElementsByTagName('smsc') ) {    #TODO move smsc to config

			push @$res,
			  {
				map { ( $_->localname => $_->textContent ) }
				  grep { $_->isa('XML::LibXML::Element') } $node->getChildNodes
			  };
		}
	} else {
		die $response->status_line;
	}

	return $self->_show_res($res);
} ## end sub request

sub do_action {
	my ( $self, $url, $action, $pass, $name, $level ) = @_;
	my $act = _get_action($action);

	return "ERROR: Can't recognise action $action!" unless $act;
	return $self->$act( "$url/$action", $pass, $name, $level );
}

sub action {
	my ( $self, $url, $pass, $name, $level ) = @_;

	my $append   = "?smsc=$name&password=$pass&level=$level";
	my $response = LWP::UserAgent->new->get( $url . $append );

	if ( $response->is_success ) {
		print $response->decoded_content, "\n";
	} else {
		die $response->status_line;
	}

	return;
}

sub _show_res {
	my ( $self, $data ) = @_;

	for ( my $i = 0 ; $data->[$i] ; $i++ ) {
		print "Element " . ( $i + 1 ) . "\n\t";
		print join "\n\t", map { "$_ => $data->[$i]{$_}" } keys %{ $data->[$i] };

		print "\n", "#" x 20, "\n" x 2;
	}

	return;
}

1;
