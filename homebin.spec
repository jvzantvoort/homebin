Summary: homebin
Name: homebin
Version: 0.0.10
Release: 1
Source0: %{name}-%{version}.tar.gz
License: MIT
Group: Development/Libraries
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Prefix: %{_prefix}/%{name}
BuildArch: noarch
Vendor: John van Zantvoort <john@vanzantvoort.org>
Url: http://vanzantvoort.org

%description
homebin

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
%{__mkdir_p} %{buildroot}%{prefix}/bin
%{__mkdir_p} %{buildroot}%{_sharedstatedir}/%{name}
%{__mkdir_p} %{buildroot}%{_sharedstatedir}/%{name}/templates/default
%{__mkdir_p} %{buildroot}%{_sharedstatedir}/%{name}/templates/local
cp README.md %{buildroot}%{_sharedstatedir}/%{name}/README.md

pushd bin
ls -1d * | while read item
do
  [[ "$item" = "build_home_setup" ]] && continue
  if [ -f $item ]
  then
    %{__install} -v -m 755 $item %{buildroot}%{prefix}/bin/$item
  fi
done
popd

# rhel8 has python3 as base
%if 0%{?rhel} == 8
pushd python3
ls -1d * | while read item
do
  if [ -f $item ]
  then
    %{__install} -v -m 755 $item %{buildroot}%{prefix}/bin/$item
  fi
done
popd
%endif


find templates -type d | while read item
do
  %{__mkdir_p} %{buildroot}%{prefix}/$item
done

pushd templates
find . -type f | while read item
do
  %{__install} -v -m 644 $item %{buildroot}%{_sharedstatedir}/%{name}/templates/$item
done
popd

(cd %{buildroot}; find . -type f | sed -e s/^.// -e /^$/d)  >> INSTALLED_FILES

%clean
rm -rf $RPM_BUILD_ROOT

%files -f INSTALLED_FILES
%defattr(-,root,root)

%changelog
* Wed Mar 27 2019 John van Zantvoort <john@vanzantvoort.org> 0.0.10-1
- Added rhe8 python3 code

* Sun Mar 24 2019 John van Zantvoort <john@vanzantvoort.org> 0.0.9-1
- stupid fix (john@vanzantvoort.org)

* Sun Mar 24 2019 John van Zantvoort <john@vanzantvoort.org> 0.0.8-1
- update for rhel8 (john@vanzantvoort.org)
- Several changes (john@vanzantvoort.org)
- adopted config options for .vimtmplrc (john@vanzantvoort.org)
- added license (john@vanzantvoort.org)

* Sun Aug 12 2018 John van Zantvoort <john@vanzantvoort.org> 0.0.7-1
- minor update (john@vanzantvoort.org)

* Sat Aug 11 2018 John van Zantvoort <john@vanzantvoort.org> 0.0.6-1
- working version of specfile (john@vanzantvoort.org)

* Sat Aug 11 2018 John van Zantvoort <john@vanzantvoort.org> 0.0.5-1
- minor fix (john@vanzantvoort.org)

* Sat Aug 11 2018 John van Zantvoort <john@vanzantvoort.org> 0.0.4-1
- add changelog (john@vanzantvoort.org)

* Sat Aug 11 2018 John van Zantvoort <john@vanzantvoort.org>
- add changelog (john@vanzantvoort.org)

