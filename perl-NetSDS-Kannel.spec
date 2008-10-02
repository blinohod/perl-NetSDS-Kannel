%define module NetSDS-Kannel

Name: perl-%module
Version: 0.9
Release: alt3

Summary: NetSDS Kannel API
Group: Development/Perl
License: GPL
Packager: Michael Bochkaryov <misha@altlinux.ru>

BuildArch: noarch
Source: %module-%version.tar.gz
Url: http://www.netstyle.com.ua/

BuildPreReq: perl-Log-Agent perl-Module-Build perl-NetSDS-Messaging perl-Test-Pod perl-Test-Pod-Coverage
# Automatically added by buildreq on Fri Aug 29 2008 (-bi)
BuildRequires: perl-Log-Agent perl-Module-Build perl-NetSDS-Messaging perl-Test-Pod perl-Test-Pod-Coverage

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
* Mon Sep 29 2008 Michael Bochkaryov <misha@altlinux.ru> 0.9-alt3
- docs update

* Thu Aug 28 2008 Grigory Milev <week@altlinux.ru> 0.1-alt2
- add noarch arch :)

* Fri Aug 15 2008 Michael Bochkaryov <misha@altlinux.ru> 0.1-alt1
- Initial Kannel API

