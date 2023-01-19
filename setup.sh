#!/bin/bash
echo "[*] Grabbing Tmux Config"
wget https://raw.githubusercontent.com/whipped5000/HTB_Scripts/main/.tmux.conf -O ~/.tmux.conf
echo "[*] Generating ~/.ssh/gitlab ssh cert"
ssh-keygen -f ~/.ssh/gitlab -N ""
cat ~/.ssh/gitlab.pub
echo "[*] Add the above key to gitlab and press any key to continue"
echo "Press any key to continue"
while [ true ] ; do
read -t 3 -n 1
if [ $? = 0 ] ; then
    echo "Host gitlab.com" > ~/.ssh/config
    echo "    Hostname gitlab.com" >> ~/.ssh/config
    echo "    IdentityFile ~/.ssh/gitlab" >> ~/.ssh/config
    echo "    IdentitiesOnly yes" >> ~/.ssh/config
    echo "[*] Cloning HTB"
    git clone git@gitlab.com:kevinjamespascoe/HTB.git
    exit 0;
fi
done
