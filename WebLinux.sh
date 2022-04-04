apt install -y git python open-vm-tools virtualenv curl

cat > /root/.bashrc  << EOFA

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;36m\]\t \[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
umask 022



HISTCONTROL=ignoredups:ignorespace
HISTFILESIZE=200000
HISTSIZE=100000

export PROMPT_COMMAND="history -a; history -n"

export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

# Some more alias to avoid making mistakes:
alias rm='rm -iv --preserve-root'
alias cp='cp -iv'
alias mv='mv -iv'
alias chmod='chmod -v --preserve-root'
alias chown='chown -v --preserve-root'
alias mount='mount -v'
alias umount='umount -flv'
alias su='su -'
alias c='clear'
alias cls='clear'
#figlet -c -f standard TROFA
#echo ########################################################################
alias plantu="netstat -plantu"
alias rgrep="find . -type f|xargs grep -win --color"
alias df="df -Th| grep -Ev '(udev|tmpfs)'"
EOFA

sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
mkdir .ssh
touch .ssh/authorized_keys
cd .ssh
ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -q -N ""
cat /root/.ssh/id_ed25519.pub >> /root/.ssh/authorized_keys 
cd /home/trofa
# http://brindi.si/g/projects/wordpot.html

git clone https://github.com/gbrindisi/wordpot.git
cd
ln -s /home/trofa/wordpot/ wordpot
cd /home/trofa/wordpot/
# pip freeze / pip list / in python help('modules')
# pip install Flask==0.10.1
# pip install git+https://github.com/pwnlandia/hpfeeds.git

# plugins https://github.com/gbrindisi/wordpot/wiki/Plugins

curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
python get-pip.py
# you get pip2 for python2
pip2 install -r requirements.txt
# edit wordpot.conf
python wordpot.py
#python wordpot --theme=twentyeleven

# create dmz on home network

##### pre-requesite to join AD #####

hostnamectl set-hostname Web.HoneypotsMonit.local
systemctl disable systemd-resolved
systemctl stop systemd-resolved
apt -y install realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit 
sudo vim /etc/resolv.conf 
        nameserver IP_OF_Domain_Controler  
realm discover HoneypotsMonit.local
sudo realm join -U administrator HoneypotsMonit.local
    ---> password for administrator:      
sudo realm list  
cat > /usr/share/pam-configs/mkhomedir << EOFA
Name: activate mkhomedir
Default: yes
Priority: 900
Session-Type: Additional
Session:
        required                        pam_mkhomedir.so umask=0022 skel=/etc/skel
EOFA
sudo pam-auth-update

#Select <OK>

sudo systemctl restart sssd
systemctl status sssd
id administrator@HoneypotsMonit
ssh administrator@HoneypotsMonit.local
apt-get install auditd audispd-plugins -y

# apt-get -y install libreadline-dev libevent-dev libdumpnet-dev libdumbnet-dev libpcre3-dev libedit-dev bison flex automake zlib1g-dev libdnet# for honeyd we didn't use in the end

##### we setup for use of forwarder #####

# splunk -> settings -> forwarding and receiving -> receiving -> port 9997
cd /opt/splunkforwarder/bin
./splunk add forward-server 192.168.7.130:9997
./splunk add monitor /var/log/audit/audit.log -index VM_WEB -sourcetype syslog
./splunk set deploy-poll Web:8089

./splunk start
# on linux iTrofa : Admin123 as forwarder-server password as asked 
# configured but inactive


# configure splunk forwarder linux https://community.splunk.com/t5/All-Apps-and-Add-ons/How-do-I-configure-a-Splunk-Forwarder-on-Linux/m-p/72078

#auditd - i restart auditd and deleted log, will add one rule now

# solution mettre Web:8089 pour le deploy-poll (127.0.0.1:8089)

# auditd and honeyfiles https://ironmoon.net/2018/05/19/File-Based-Honeypots-with-Auditd.html

#### File Integrity Monitoring ####

#apt-cache policy aide => interesting command tells us versions in debian repos
# for aide they aren't the most up to date

apt -y install aide

# we got hostname error to solve -> in 127.0.0.1 /etc/hosts and /etc/hostname it must be the same, no spaces, 1 period

aideinit

cp /var/lib/aide/aide.db{.new,}
# add the following line to /etc/aide/aide.conf

report_url=syslog:LOG_AUTH


#### Honeypot Cowrie #### https://wjmccann.github.io/blog/2017/08/17/Cowrie-Honeypot-and-Splunk

apt-get install git virtualenv libssl-dev libffi-dev build-essential libpython-dev python2.7-minimal authbind python2.7-dev iptables
adduser --disabled-password cowrie
su cowrie
git clone http://github.com/micheloosterhof/cowrie
cd cowrie
virtualenv cowrie-env
source cowrie-env/bin/activate
pip install -r requirements.txt
cd etc
cp cowrie.cfg.dist cowrie.cfg
# change ssh port to other than 22
iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222
iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 222 # for SSH Bruteforcing alert test
# it's now installed  - we now install tango honeypot splunk helper
git clone https://github.com/aplura/Tango.git /tmp/tango; chmod +x /tmp/tango/uf_only.sh
cd /tmp/tango/
./uf_only.sh # correct script link doesn't work vmware login i think
# remove error checks and sudo command and wget 
# Log file to watch for /home/cowrie/cowrie/var/log/cowrie/cowrie.log
# use trello helps
# get script to monitor attack
# go to settings -> roles -> admin default indexes -> give index "honeypot" right column and save
# had to use splunkforwarder backup because of chown issues, root:root works for both indexes

#### Bonus Endlessh Port 2222 look for github ####


######## AD search queries for Linux Web #########

# List of failed login attempts by users
index="vm_web" type=user_login res=failed | stats count by acct| sort - count 
# Alert created : every 5 minutes, triggered alert - critical #


 
######## Attack script to trigger alerts etc.. ########

hydra -vV -I -l root -s 22 -t 3 -P password.txt ssh://192.168.7.128
# lynis
git clone https://github.com/CISOfy/lynis
cd lynis && ./lynis audit system
