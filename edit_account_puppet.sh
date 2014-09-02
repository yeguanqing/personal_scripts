#!/bin/bash

PATH=/etc/puppet/modules/users/manifests

function adduser ()

{			while true
			do
			echo -n "Enter the user name:"
                        read user
			cd $PATH
			list=`/bin/grep ":" *.pp | /bin/grep -v "#" | /bin/awk -F ":" '{print $2}' | /bin/awk -F "'" '{print $2}' | /bin/grep -v "^$" | /bin/grep -w ${user}`	
			if [ "$list"x = "$user"x ];then
			echo -e "\033[36mThe account ${user} is exist,please change the username...\033[0m"
			break
			else
                        echo -n "Enter the password:"
                        read passwd
			cd $PATH ; /bin/sed -i "/#User/a\user { \n\t'${user}': \n\tensure\t\t=> present, \n\tcomment\t\t=> '${user}', \n\tgroups\t\t=> [ '${G}' ], \n\tpassword\t=> '${passwd}', \n\tmanagehome\t=> true, \n\tshell\t\t=> \"/bin/bash\", \n}" ${G}.pp
			echo -e "\033[36mThe account ${user} has been added to the group ${G}!\033[0m"
			fi
			echo -n "Do you want to add to this group: [y/n]:"
               		read go
                        if [ "${go}" == "n" -o "${go}" == "N" ]
                        then
			cd $PATH; /usr/bin/svn commit -m "Add the new account $user to the group $G." && /usr/bin/svn update
                        break
                        fi
			done
}

while true 
do 
echo "----------------------Menu----------------------" 
echo "(1) Add the new user" 
echo "(2) Del the user" 
echo "(3) Change the password" 
echo "(0) exit" 
echo "-------------------------------------------------" 

echo -n "enter you chose[0-3]:" 
read num 
if [ ${num} -lt 0 -o ${num} -gt 3 ] 
    then 
      echo "this is not between 0-3" 
else 
   if [ "${num}" == "1" ] 
      then 
      #cd $PATH; /usr/bin/svn update
	  
		while [ "1" == "1" ]
		do
		echo "---------------------Select The Group-------------------"
		echo "(1) dev_ada"
		echo "(2) dev_aoi"
		echo "(3) dev_open"
		echo "(4) netops"
		echo "(5) dev_apkprotect"
		echo "(6) dev_design"
		echo "(7) dev_fpploc"
		echo "(8) dev_inappbilling"
		echo "(9) dev_omae"
		echo "(10) dev_omp"
		echo "(11) dev_omss"
		echo "(12) dev_oss"
		echo "(13) dev_softsim"
		echo "(14) dev_sso"
		echo "(15) dev_tools"
		echo "(16) other"
		echo "(17) qa"
		echo "--------------------------------------------------------"
		echo -n "enter your chose[1-17]:"
		read group
		if [ "${group}" == 1 ]
			then
			G='dev_ada'
		        adduser
	        elif [ "${group}" == 2 ]
			then
			G='dev_aoi'
			adduser
		elif [ "${group}" == 3 ]
                        then
                        G='dev_open'     
                        adduser
		elif [ "${group}" == 4 ]
                        then
                        G='netops'
                        adduser
                elif [ "${group}" == 5 ]
                        then
                        G='dev_apkprotect'
                        adduser		
		elif [ "${group}" == 6 ]
                        then
                        G='dev_design'
                        adduser
                elif [ "${group}" == 7 ]
                        then
                        G='dev_fpploc'
                        adduser
                elif [ "${group}" == 8 ]
                        then
                        G='dev_inappbilling'
                        adduser
                elif [ "${group}" == 9 ]
                        then
                        G='dev_omae'
                        adduser  
		elif [ "${group}" == 10 ]
                        then
                        G='dev_omp'
                        adduser
                elif [ "${group}" == 11 ]
                        then
                        G='dev_omss'
                        adduser
                elif [ "${group}" == 12 ]
                        then
                        G='dev_oss'
                        adduser
                elif [ "${group}" == 13 ]
                        then
                        G='dev_softsim'
                        adduser
                elif [ "${group}" == 14 ]
                        then
                        G='dev_sso'
                        adduser 
		elif [ "${group}" == 15 ]
                        then
                        G='dev_tools'
                        adduser
                elif [ "${group}" == 16 ]
                        then
                        G='other'
                        adduser
                elif [ "${group}" == 17 ]
                        then
                        G='qa'
                        adduser
		else
			break
		fi
		echo -n "Do you want to add to other groups: [y/n]:"
		read go
		if [ "${go}" == "n" -o "${go}" == "N" ]
		   then
		   break
		   fi
		done
else
    if [ "${num}" == "2" ]
	 then
		 while [ "1" == "1" ] 
	 	 do
		 echo "---------------------Del The User-------------------"
		 echo -n "Please enter the username to delete:"
                 read delname
		 cd $PATH
		 dir=`/bin/ls -l | /bin/awk '{print $9}' | /bin/grep -v "^$" | /bin/grep -v "*.bak"`
		 for file in $dir
		 do
		 line=`/bin/cat -n $file | /bin/grep -w ${delname} | /usr/bin/head -1 | /bin/awk '{print $1}'`
		 newline=$[line+1]
		 /bin/sed -i "$newline s/present,/absent,/g" $file
		 done	
		 #/bin/sed -n "$newline p" $file
		 echo -e "\033[36mThe account ${delname} has been deleted...\033[0m"
		 cd $PATH ; /usr/bin/svn commit -m "${delname} has been deleted." && /usr/bin/svn update
		 echo -n "do you want to continue to delete: [y/n]:"
                 read go
                 if [ "${go}" == "n" -o "${go}" == "N" ]
                   then
                   break
		 fi
		 done
else
    if [ "${num}" == "3" ]
         then
                 while [ "1" == "1" ] 
                 do
		 echo "---------------------Change The User Password-------------------"
		 echo -n "Please enter the username:"
		 read changename
		 echo -n "Please enter the new password:" 
		 read newpass
		 password=$(echo "$newpass" | /bin/sed -r "s+\\$+\\\\$+g")
		 cd $PATH
		 dir=`/bin/ls -l | /bin/awk '{print $9}' | /bin/grep -v "^$" | /bin/grep -v "*.bak"`
		 for file in $dir
		 do
		 line=`/bin/cat -n $file | /bin/grep -w ${changename} | /usr/bin/head -1 | /bin/awk '{print $1}'`
		 newline=$[line+4]
		 /bin/sed -i -r -e "$newline s/'([^']*)'/'111'/" -e  s+111+$password+ $file

		 done	
		 echo  -e "\033[36mAlready changed the new password for $changename...\033[0m"
		 cd $PATH ; /usr/bin/svn commit -m "changed the new password for $changename" && /usr/bin/svn update
		 echo -n "do you want to continue to change the password: [y/n]:"
                 read go
                 if [ "${go}" == "n" -o "${go}" == "N" ]
                   then
                   break
                 fi
		 done
	exit
fi
 fi
  fi
   fi
echo -n "Do you contine [y/n]:" 
read go
if [ "${go}" == "n" -o "${go}" == "N" ]
   then
   exit
fi
done
