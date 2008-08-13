%define module NetSDS-Kannel

Name: perl-NetSDS-Kannel
Version: 0.1
Release: alt1

Summary: NetSDS Kannel API
Group: Development/Perl
License: GPL
Packager: Michael Bochkaryov <misha@altlinux.ru>

Source: %module-%version.tar.gz
Url: http://www.netstyle.com.ua/

# Automatically added by buildreq on Wed Nov 06 2002
BuildRequires: perl-devel

%description
None.

%prep
%setup -q -n %module

%build
%perl_vendor_build

%install
%perl_vendor_install

%files
%perl_vendor_privlib/NetSDS*
%perl_vendor_man3dir/*

%changelog
