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