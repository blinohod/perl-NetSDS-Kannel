%define module NetSDS-Kannel

Name: perl-%module
Version: 0.1
Release: alt1

Summary: NetSDS Kannel API
Group: Development/Perl
License: GPL
Packager: Michael Bochkaryov <misha@altlinux.ru>

BuildArch: noarch

Source: %module-%version.tar.gz
Url: http://www.netstyle.com.ua/

BuildPreReq: perl-Log-Agent perl-Module-Build perl-NetSDS-Messaging perl-Test-Pod perl-Test-Pod-Coverage
# Automatically added by buildreq on Wed Nov 06 2002
BuildRequires: perl-devel

%description
None.

%prep
%setup -q -n %module-%version

%build
%perl_vendor_build

%install
%perl_vendor_install

%files
%perl_vendor_privlib/NetSDS*
%perl_vendor_man3dir/*

%changelog
* Fri Aug 15 2008 Michael Bochkaryov <misha@altlinux.ru> 0.1-alt1
- Initial Kannel API

