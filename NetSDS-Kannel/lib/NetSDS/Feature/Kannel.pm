#===============================================================================
#
#         FILE:  Kannel.pm
#
#  DESCRIPTION:  NetSDS::Feature::Kannel - kannel application feature
#
#        NOTES:  ---
#       AUTHOR:  Michael Bochkaryov (RATTLER), <misha@rattler.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  07.09.2008 21:26:08 EEST
#===============================================================================
=head1 NAME

NetSDS::Feature::Kannel - kannel application feature

=head1 SYNOPSIS

	use NetSDS::;

=head1 DESCRIPTION

C<NetSDS::Feature::Kannel> module provides pluggable API to Kannel
from NetSDS application.

=cut

package NetSDS::Feature::Kannel;

use 5.8.0;
use strict;
use warnings;

use NetSDS::Kannel;
use base qw(NetSDS::Class::Abstract);

use version; our $VERSION = "1.100";

#===============================================================================
#
=head1 CLASS METHODS

=over

=item B<new([...])>

Constructor

    my $object = NetSDS::SomeClass->new(%options);

=cut

#-----------------------------------------------------------------------
sub new {

	my ( $class, $app, $conf ) = @_;

	my $kannel = NetSDS::Kannel->new(%{$conf});

	$app->log("info", "Kannel feature loaded...");

	return $kannel;

};


1;

__END__

=back

=head1 EXAMPLES

None

=head1 BUGS

Unknown yet

=head1 SEE ALSO

None

=head1 TODO

None

=head1 AUTHOR

Michael Bochkaryov <misha@rattler.kiev.ua>

=cut


