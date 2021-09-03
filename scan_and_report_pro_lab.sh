
#!/bin/bash

# Variables - Change to suit lab

# The base network
base_net=10.10.110.0/24
# Name of the Pro Lab, for Obsidian
pro_lab=Genesis

#
echo "***********************************************************************************************"
echo "Run this script from a directory you are going to store the results in"
echo "It will do a ping sweep for hosts, followed by a port scan of all ports"
echo "It will then do a -sC -sV scan of the discovered ports and finally output everything to a notes"
echo "directory that can be used with Obsidian"
echo "***********************************************************************************************"
echo ""
read -n 1 -s -r -p "Press any key to continue"

#################################################################
# Do a ping scan if we haven't already done one
#################################################################
echo "# - ping scanning network $base_net"
if [[ ! -d nmap ]]
then
  mkdir nmap
fi

if [[ ! -f hosts ]]
then
  sudo nmap -v -sn -oA nmap/hosts $base_net 2>&1 >/dev/null
  cat nmap/hosts.gnmap | grep Up | awk '{print $2}' > hosts
else
  echo "# - hosts file exists. To rescan subnet, delete file"
fi

echo "# - Found the following hosts"
cat hosts

#################################################################
# End of Ping Scan
#################################################################


#################################################################
# All Ports Scan of discovered hosts - Optional
#################################################################
if [[ ! -f .all_scan_done ]]
then
# Do an all ports scan on each host
  for i in $(cat hosts)
  do
    if [[ ! -d $i ]]
    then
      mkdir -p $i/nmap
    fi

    echo "# - Scanning all ports on host $i"
    sudo nmap -p- -oA $i/nmap/all_ports $i 2>&1 >/dev/null
  done
  touch .all_scan_done
else
  echo "# - Skipping all ports scan. Delete .all_scan_done to rerun"
fi


#################################################################
# End of All Ports Scan
#################################################################


#################################################################
# Detailed scan of discovered ports for each host - optional
#################################################################

if [[ ! -f .detailed_scan_done ]]
then
  # Do a detailed ports scan on the ports discovered for each host
  for i in $(cat hosts)
  do
    echo "# - Detailed Scanning of discovered ports on host $i"
    ports=$(cat $i/nmap/all_ports.nmap | grep open | awk -F'/' '{print $1}' | tr '\n' ',')
    sudo nmap -p $ports -sC -sV -oA $i/nmap/all_ports_detailed $i 2>&1 >/dev/null
  done
  touch .detailed_scan_done
else
  echo "# - Skipping detailed ports scan. Delete .detailed_scan_done to rerun"
fi


#################################################################
# End of Detailed Scan
#################################################################



#################################################################
# Output results to Markdown Files
#################################################################

echo "# - Writing to Markdown Files"
for i in $(cat hosts)
do
  if [[ ! -d notes/$pro_lab/$i ]]
  then
    mkdir notes/$pro_lab/$i
  fi
  echo "## All Port Scan - $i" > "notes/$pro_lab/$i/00 - nmap.md"
  echo '```bash' >> "notes/$pro_lab/$i/00 - nmap.md"
  cat $i/nmap/all_ports.nmap | grep open >> "notes/$pro_lab/$i/00 - nmap.md"
  echo '```' >> "notes/$pro_lab/$i/00 - nmap.md"
  echo "## All Port Details - $i" >> "notes/$pro_lab/$i/00 - nmap.md"
  echo '```bash' >> "notes/$pro_lab/$i/00 - nmap.md"
  cat $i/nmap/all_ports_detailed.nmap >> "notes/$pro_lab/$i/00 - nmap.md"
  echo '```' >> "notes/$pro_lab/$i/00 - nmap.md"
done


#################################################################
# End of Output results
#################################################################
