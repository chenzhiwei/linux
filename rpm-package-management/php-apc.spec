%global php_extdir  %(php-config --extension-dir 2>/dev/null || echo "undefined")
%global php_apiver  %((echo 0; php -i 2>/dev/null | sed -n 's/^PHP API => //p') | tail -1)

Name:           php-apc
Version:        3.1.9
Release:        1
Summary:        A module for PHP applications speeder

Group:          Development/Languages
License:        PHP
URL:            http://www.php.net/
Source0:        http://www.php.net/distributions/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  php-devel
Requires:       php(api) = %{php_apiver}

%description
The Alternative PHP Cache (APC) is a free and open opcode cache for PHP. Its goal is to provide a free, open, and robust framework for caching and optimizing PHP intermediate code.

%prep
%setup -q

%build
%{_bindir}/phpize
%configure
%{__make} %{?_smp_mflags}

%install
%{__rm} -rf $RPM_BUILD_ROOT
%{__mkdir} -p $RPM_BUILD_ROOT%{_sysconfdir}/php.d
%{__make} install INSTALL_ROOT=$RPM_BUILD_ROOT
%{__cat} > $RPM_BUILD_ROOT%{_sysconfdir}/php.d/apc.ini <<EOF
; Enable apc extension module
extension=apc.so
EOF

%clean
%{__rm} -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%config(noreplace) %{_sysconfdir}/php.d/apc.ini
%{php_extdir}/*.so
/usr/include/php/ext/apc/apc_serializer.h

%changelog
* Sat Jan 08 2013 Chen Zhiwei <zhiweik@gmail.com> - 3.1.9-1
- Build php-apc package
