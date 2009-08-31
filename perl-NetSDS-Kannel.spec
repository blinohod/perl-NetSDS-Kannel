%define module NetSDS-Kannel

Name: perl-%module
Version: 1.200
Release: alt2

Summary: NetSDS Kannel API
Group: Development/Perl
License: GPL
Packager: Michael Bochkaryov <misha@altlinux.ru>

BuildArch: noarch
Source: %module-%version.tar.gz
Url: http://www.netstyle.com.ua/

# Automatically added by buildreq on Thu Jul 30 2009 (-bi)
BuildRequires: perl-Module-Build perl-NetSDS perl-NetSDS-Util perl-Test-Pod perl-Test-Pod-Coverage perl-XML-LibXML perl-libwww

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
%_bindir/kannel-admin
%_man1dir/*
%doc samples

%changelog
* Mon Aug 31 2009 Michael Bochkaryov <misha@altlinux.ru> 1.200-alt2
- Fix build requirements

* Thu Jul 30 2009 Michael Bochkaryov <misha@altlinux.ru> 1.200-alt1
- NetSDS::Kannel::Admin added
- CLI admin tool added

* Fri Jul 24 2009 Michael Bochkaryov <misha@altlinux.ru> 1.100-alt1
- fixed build with new NetSDS framework
- changed versioning rules

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

