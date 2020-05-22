#!/bin/bash

# Just Another Linux Enumerator
version="version 0.0.3"

# run as low-privilege user
# inspired by LinEnum

# usage and help

usage() {
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo "| Just Another Linux Enumerator        |"
    echo "|                github: kegn          |"
    echo "|                $version              |"
    echo "|                                      |" 
    echo "|                                      |"
    echo "|                                      |"
    echo "| ex: ./yale.sh root                   |"
    echo "|     ./yale.sh www-data               |"
    echo "|                                      |"
    echo "++++++++++++++++++++++++++++++++++++++++"
}

# color definitions
green() {
    echo -e "\e[32m$*"
}

yellow() {
    echo -e "\e[33m$*"
}

cyan() {
    echo -e "\e[36m$*"
}

# reset echo foreground color
echofg() {
    echo -e "\e[39m$*"
}
header() {
     green "++++++++++++++++++++++++++++++++++++++++" 2>/dev/null
     yellow "  Just Another Linux Enumerator         " 2>/dev/null
     green "++++++++++++++++++++++++++++++++++++++++" 2>/dev/null
}

target_user() {
echo ""        
green "++++++++++++++++++++++++++++++++++++++++" 2>/dev/null
yellow " Target User: $TARGET_USER             " 2>/dev/null
green "++++++++++++++++++++++++++++++++++++++++" 2>/dev/null
}

# for proper output spacing
spacing() {
sed -e 's/^/               /g' 2>/dev/null
}

system_info() {
echo ""
cyan " ----- System Information -----" 2>/dev/null
echofg 2>/dev/null
echo "hostname     : $(cat /etc/hostname 2>/dev/null)"
echo "current user : $(whoami 2>/dev/null)"
echo "uname -a     : $(uname -a 2>/dev/null)"
echo "proc version : $(cat /proc/version 2>/dev/null)"
echo "selinux      : $(sestatus 2>/dev/null)"
echo "shells       : "
cat /etc/shells | grep -v "#" 2>/dev/null | spacing
echo "release info : "
echo "$(cat /etc/*-release 2>/dev/null | spacing)"
}

user_info() {
echo ""
cyan " ----- User Information ----- " 2>/dev/null
echofg 2>/dev/null
echo "current user : $(whoami 2>/dev/null)"
echo "id           : $(id 2>/dev/null)"
echo "PATH         : $(echo $PATH 2>/dev/null)"
echo "umask        : $(umask 2>/dev/null)"
echo "groups       : $(groups 2>/dev/null)"
echo "group mems   : "
echo "$(for i in $(cat /etc/passwd 2>/dev/null | cut -d":" -f1 2>/dev/null); do echo $i : $(id $i 2>/dev/null) | spacing; done)"
echo "lastlog      : "
echo "$(lastlog 2>/dev/null | grep -v "Never" 2>/dev/null | spacing)"
echo "logged on    : "
echo "$(w 2>/dev/null | spacing)"
}

common_files() {
echo ""
cyan " ----- Common Files ----- " 2>/dev/null
echofg 2>/dev/null
echo "/etc/passwd: "
cat /etc/passwd 2>/dev/null | spacing
echo ""

shadow=$(cat /etc/shadow 2>/dev/null)
if [ "$shadow" ];
then
    echo ""
    echo "/etc/shadow: "
    cat /etc/shadow 2>/dev/null | spacing
fi

sudoers=$(cat /etc/sudoers 2>/dev/null)
if [ "$sudoers" ];
then
    echo ""
    echo "/etc/sudoers: "
    cat /etc/sudoers 2>/dev/null | grep -v "#" 2>/dev/null | spacing
fi
}

# fix to / instead of .
writable_files() {
echo ""
cyan " ----- Writable Files ----- " 2>/dev/null
echofg 2>/dev/null
echo "files that we do NOT own:"
find / -writable ! -user $(whoami) -type f ! -path "proc/*" ! -path "/sys/*" -exec ls -alh {} \; 2>/dev/null | spacing
echo ""
echo "files that we do own:"
find / -writable -user $(whoami) -type f ! -path "proc/*" ! -path "/sys/*" -exec ls -alh {} \; 2>/dev/null | spacing

}

# fix to / instead of .
writable_dirs() {
echo ""
cyan echo " ----- Writable Directories ----- " 2>/dev/null
echofg 2>/dev/null
echo "directories that we do NOT own:"
find / -writable ! -user $(whoami) -type d ! -path "proc/*" ! -path "/sys/*" 2>/dev/null | spacing
echo ""
echo "directories that we do own:"
find / -writable -user $(whoami) -type d ! -path "proc/*" ! -path "/sys/*" 2>/dev/null | spacing
}

hidden_files() {
echo ""
cyan " ----- Hidden Files ----- " 2>/dev/null
echofg 2>/dev/null
echo "hidden files:"
find / -name ".*" -type f ! -path "proc/*" ! -path "/sys/*" -exec ls -alh {} \; 2>/dev/null | spacing
}

environment() {
echo ""
cyan " ----- Environment ----- "
echofg 2>/dev/null
env 2>/dev/null | grep -v 'LS_COLORS' 2>/dev/null | spacing
}

network_info() {
echo ""
cyan " ----- Network Info -----" 2>/dev/null
echofg 2>/dev/null
echo "ip info:"
/sbin/ifconfig -a 2>/dev/null | spacing
echo "arp info:"
arp -a 2>/dev/null | spacing
echo "/etc/resolv.conf:"
cat /etc/resolv.conf 2>/dev/null | spacing
echo "route info:"
route 2>/dev/null | spacing
echo "netstat Listen TCP:"
netstat -tlpn 2>/dev/null
echo "netstat Listen UDP:"
netstat -ulpn 2>/dev/null

}

svc_info() {
echo ""
cyan " ----- Service Info ----- " 2>/dev/null
echofg 2>/dev/null
echo "processes: ps aux: "
ps aux 2>/dev/null

echo "process permissions: "
ps aux 2>/dev/null | awk '{print $11}' | xargs -r ls -la 2>/dev/null | awk '!x[$0]++' 2>/dev/null | spacing

}

software_versions() {
echo ""
cyan " ----- Software Versions ----- " 2>/dev/null
echofg 2>/dev/null
echo "MYSQL Version    : $(mysql --version 2>/dev/null)"
echo "Apache Version   : $(apache2 -v 2>/dev/null | head -n 1 2>/dev/null)"
echo "Docker Version   : $(docker --version 2>/dev/null)"
echo "Sudo Version     : $(sudo -V 2>/dev/null | grep 'Sudo version')"
    
}


# eventually add discovery of virtualhosts
# enabled_websites() {
#     # check apache2 default config
#     ls /etc/apache2 > /dev/null 2>&1
#     if [ $? -eq 0 ]
#     then
#         echo "apache2 site enabled:"
#         cat /etc/apache2/sites-enabled/* | grep "Document"
# 
#     fi
# 
# }


#### MAIN SCRIPT ####

if [ -n "$1" ]
    # test to see if target username is specified
then 
    TARGET_USER=$1
else
    TARGET_USER="root"
fi

main() {
header
target_user
system_info
user_info
common_files
writable_files
writable_dirs
hidden_files
environment
network_info
svc_info
software_versions
}

# call main
main


