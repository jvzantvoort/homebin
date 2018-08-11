%define name homebin
%define version 0.0.3
%define unmangled_version 0.0.3
%define release 1

Summary: homebin
Name: %{name}
Version: %{version}
Release: %{release}
Source0: %{name}-%{unmangled_version}.tar.gz
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
