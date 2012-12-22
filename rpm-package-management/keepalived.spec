%define __packager zhiwei
Summary: HA monitor built upon LVS, VRRP and services poller
Name: keepalived
Version: 1.2.7
Release: 1
License: GPL
Group: Applications/System
URL: http://www.keepalived.org/
Packager: %{__packager}

Source0: http://www.keepalived.org/software/keepalived-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

BuildArch: x86_64
BuildRequires: openssl-devel
# We need both of these for proper LVS support
BuildRequires: kernel, kernel-devel
Requires(post): /sbin/chkconfig
Requires(preun): /sbin/service, /sbin/chkconfig
Requires(postun): /sbin/service

%description
The main goal of the keepalived project is to add a strong & robust keepalive
facility to the Linux Virtual Server project. This project is written in C with
multilayer TCP/IP stack checks. Keepalived implements a framework based on
three family checks : Layer3, Layer4 & Layer5/7. This framework gives the
daemon the ability to check the state of an LVS server pool. When one of the
servers of the LVS server pool is down, keepalived informs the linux kernel via
a setsockopt call to remove this server entry from the LVS topology. In
addition keepalived implements an independent VRRPv2 stack to handle director
failover. So in short keepalived is a userspace daemon for LVS cluster nodes
healthchecks and LVS directors failover.

%prep
%setup

%build
%configure
%{__make}

%install
%{__rm} -rf %{buildroot}
%{__make} install DESTDIR=%{buildroot}
%{__rm} -rf %{buildroot}%{_sysconfdir}/keepalived/samples/

%check
# A build could silently have LVS support disabled if the kernel includes can't
# be properly found, we need to avoid that.
if ! grep -q "IPVS_SUPPORT='_WITH_LVS_'" config.log; then
    echo "ERROR: We do not want keeepalived lacking LVS support."
    exit 1
fi

%clean
%{__rm} -rf %{buildroot}

%pre
echo "commands before install this rpm package"

%post
echo "commands after install this rpm package"
/sbin/chkconfig --add keepalived

%preun
echo "commands before uninstall this rpm package"
if [ $1 -eq 0 ]; then
    /sbin/service keepalived stop &>/dev/null || :
    /sbin/chkconfig --del keepalived
fi

%postun
echo "commands after uninstall this rpm package"
if [ $1 -ge 1 ]; then
    /sbin/service keepalived condrestart &>/dev/null || :
fi

%files
%defattr(-, root, root, 0755)
%doc AUTHOR ChangeLog CONTRIBUTORS COPYING README TODO
%doc doc/keepalived.conf.SYNOPSIS doc/samples/
%dir %{_sysconfdir}/keepalived/
%attr(0600, root, root) %config(noreplace) %{_sysconfdir}/keepalived/keepalived.conf
%attr(0600, root, root) %config(noreplace) %{_sysconfdir}/sysconfig/keepalived
%{_sysconfdir}/rc.d/init.d/keepalived
%{_bindir}/genhash
%{_sbindir}/keepalived
%{_mandir}/man1/genhash.1*
%{_mandir}/man5/keepalived.conf.5*
%{_mandir}/man8/keepalived.8*

%changelog
* Thu Sep 13 2007 Alexandre Cassen <acassen@linux-vs.org> 1.1.14
- Merge work done by freshrpms.net... Thanks guys !!! ;)

* Wed Feb 14 2007 Matthias Saou <http://freshrpms.net/> 1.1.13-5
- Add missing scriplet requirements.
