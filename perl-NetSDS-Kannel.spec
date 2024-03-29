%define module NetSDS-Kannel
%def_without test

Name: perl-%module
Version: 2.0.1
Release: alt1

Summary: NetSDS Kannel API
Group: Development/Perl
License: GPL
Packager: Michael Bochkaryov <misha@altlinux.ru>

BuildArch: noarch
Source: %module-%version.tar.gz
Url: http://www.netstyle.com.ua/

# Automatically added by buildreq on Thu Jul 30 2009 (-bi)
BuildRequires: perl-Module-Build 
BuildRequires: perl-NetSDS 
BuildRequires: perl-Test-Pod 
BuildRequires: perl-Test-Pod-Coverage 
BuildRequires: perl-XML-LibXML 
BuildRequires: perl-libwww

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
%doc samples

%changelog
* Sun Feb 05 2012 Michael Bochkaryov <misha@altlinux.ru> 2.0.1-alt1
- Fix DLR URL to send message-ID from SMSC instead of internal Kannel
- Build.PL processed with perltidy
- Versioning changed to three-digit pattern

* Mon Oct 24 2011 Dmitriy Kruglikov <dkr@altlinux.ru> 2.000-alt1
- Removed perl-NetSDS-Util from BuildRequres

* Fri Oct 21 2011 Michael Bochkaryov <misha@altlinux.ru> 2.000-alt0
- Fixed empty messages processing
- No man pages in RPM

* Sat Apr 03 2010 Michael Bochkaryov <misha@altlinux.ru> 1.301-alt1
- Documentation improvements
- MWI support in send() method

* Sat Jan 09 2010 Michael Bochkaryov <misha@altlinux.ru> 1.300-alt1
- 1.300

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

