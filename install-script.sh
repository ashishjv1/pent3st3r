##Install-Script##
#!/bin/bash

test -d Sublist3r && echo "tool exists" || git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r && pip install -r requirements.txt 
cd ..
sleep 4
if ! [ -x "$(command -v dnsrecon)" ]; then
  sudo apt install dnsrecon
fi 
sleep 4
if ! [ -x "$(command -v altdns)" ]; then
  sudo pip install py-altdns
fi
sleep 4
test -d massdns && echo "tool exists" || git clone https://github.com/blechschmidt/massdns.git 
cd massdns && make
cd ..
sleep 4
if ! [ -x "$(command -v amass)" ]; then
  apt install amass
fi 
sleep 4
git clone https://github.com/yanxiu0614/subdomain3.git
cd subdomain3 && pip install -r requirement.txt
cd ..
echo "checking Installation"
test -d Sublist3r && echo "Sublist3r Installed" || echo "error"
test -d massdns  && echo "Massdns Installed" || echo "error"

if ! [ -x "$(command -v dnsrecon)" ]; then
  echo 'Error: dnsrecon is not installed.' 
  echo 'You are on Your Own now. Please Solve the installation errors manually'
fi 

if ! [ -x "$(command -v altdns)" ]; then
  echo 'Error: altdns is not installed.' 
  echo 'You are on Your Own now. Please Solve the installation errors'
fi

if ! [ -x "$(command -v amass)" ]; then
  echo 'Error: amass is not installed.' 
  echo 'You are on Your Own now. Please Solve the installation errors'
fi