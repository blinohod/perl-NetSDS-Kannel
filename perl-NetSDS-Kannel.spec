%define module NetSDS-Kannel

Name: perl-%module
Version: 1.1
Release: alt1

Summary: NetSDS Kannel API
Group: Development/Perl
License: GPL
Packager: Michael Bochkaryov <misha@altlinux.ru>

BuildArch: noarch
Source: %module-%version.tar.gz
Url: http://www.netstyle.com.ua/

# Automatically added by buildreq on Fri Jul 24 2009 (-bi)
BuildRequires: perl-Module-Build perl-NetSDS-Util perl-Test-Pod perl-Test-Pod-Coverage

%description
NetSDS::Kannel provides simple perl API to Kannel SMSC gateway.

%prep
%setup -q -n %module-%version

%build
%perl_vendor_build

%install
%perl_vendor_install

%files
%perl_vendor_privlib/NetSDS*
%perl_vendor_man3dir/*
%doc samples

%changelog
* Sun Nov 23 2008 Michael Bochkaryov <misha@altlinux.ru> 1.1-alt1
- 1.1 version
- samples packaged
- basic test cases added

* Mon Sep 29 2008 Michael Bochkaryov <misha@altlinux.ru> 0.9-alt3
- docs update

* Thu Aug 28 2008 Grigory Milev <week@altlinux.ru> 0.1-alt2
- add noarch arch :)

* Fri Aug 15 2008 Michael Bochkaryov <misha@altlinux.ru> 0.1-alt1
- Initial Kannel API

