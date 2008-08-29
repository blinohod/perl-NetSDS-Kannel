#!/usr/bin/env perl
########################################################################
# $Id: Build.PL 27 2008-07-21 23:23:15Z anvil $
########################################################################

=head1 NAME

Build.PL - Build script generator for NetSDS Nibelite integration

=head1 SYNOPSIS

 perl Build.PL
 ./Build
 ./Build test
 ./Build install

=cut

use strict;
use warnings 'all';

# force commit
our $VERSION = "0.9";

use Module::Build;

my $build = Module::Build->new(
	module_name        => 'NetSDS::Kannel',
	dist_name          => 'NetSDS-Kannel',
	dist_version       => $VERSION,
	dist_abstract      => 'Kannel API for NetSDS VAS platform',
	create_makefile_pl => 'traditional',
	dist_author        => 'Net.Style Development Team <info@netstyle.com.ua>',
	create_readme      => 1,
	license            => 'gpl',
	build_requires     => {
		'Test::More'          => '0.62',
		'Test::Pod'           => '1.26',
		'Test::Pod::Coverage' => '1.08',
		'Module::Build'       => '0.2805',
	},
	requires => {
		'version'                 => '0.50',
		'perl'                    => '5.008',
		'NetSDS::App'             => '0.01',
		'NetSDS::Class::Abstract' => '0.01',
	},
	recommends => {
	},
	script_files => {},
);

$build->create_build_script;

__END__

=head1 AUTHOR

Michael Bochkaryov <misha@rattler.kiev.ua>

=cut
