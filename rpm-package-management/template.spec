Name:		
Version:	
Release:	1%{?dist}
Summary:	

Group:		
License:	
URL:		
Source0:	
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildRequires:	
Requires:	
AutoReq: 0
AutoProv: 0
AutoReqProv: 0

%description

%prep
%setup -q

%build
%configure
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%pre
echo "before install"

%post
echo "after install"

%preun
echo "before uninstall"

%postun
echo "after uninstall"

%files
%defattr(-,root,root,-)
%attr(0600, root, root) %config(noreplace) %{_sysconfdir}/application/app.conf
%attr(0755, root, root) /etc/rc.d/init.d/application
%doc

%changelog
