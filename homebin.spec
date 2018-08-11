Summary: homebin
Name: homebin
Version: 0.0.4
Release: 1
Source0: %{name}-%{version}.tar.gz
License: MIT
Group: Development/Libraries
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Prefix: %{_prefix}
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
%{__mkdir_p} %{buildroot}%{prefix}/templates
%{__mkdir_p} %{buildroot}%{_sharedstatedir}/%{name}


# ── bin
#    ├── build_home_setup
#    ├── center_text
#    ├── difftree
#    ├── edit
#    ├── git2cl
#    ├── git-fix
#    ├── glossary
#    ├── ip2hex
#    ├── mvx
#    ├── myterm
#    ├── purgeemptydirs
#    ├── resume
#    ├── resume_screen
#    ├── resume_tmux
#    ├── setup_dirs
#    ├── setup_git
#    ├── setup_rpmgpg
#    ├── today
#    ├── uudecode
#    ├── vimtmpl
#    ├── vimtmpl_bash -> vimtmpl
#    ├── vimtmpl_playbook -> vimtmpl
#    ├── vimtmpl_python -> vimtmpl
#    ├── winapg
#    └── wpylint
# ── export_homebin.sh
# ── homebin.spec
# ── LICENSE
# ── README.md
# ── templates
#    ├── default
#    │   ├── bash.template
#    │   ├── playbook.template
#    │   └── python.template
#    └── local

cp README.md %{buildroot}%{_sharedstatedir}/%{name}/README.md
cd bin
ls -1d * | while read item
do
  if [ -f $item ]
  then
    %{__install} -v -m 755 $item %{buildroot}%{prefix}/bin/$item
  fi
done
cd -

%clean
rm -rf $RPM_BUILD_ROOT

%files -f INSTALLED_FILES
%defattr(-,root,root)

%changelog
* Sat Aug 11 2018 John van Zantvoort <john@vanzantvoort.org> 0.0.4-1
- add changelog (john@vanzantvoort.org)

* Sat Aug 11 2018 John van Zantvoort <john@vanzantvoort.org>
- add changelog (john@vanzantvoort.org)

