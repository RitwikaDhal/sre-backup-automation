#checking the disk usage on all the nodes
du -sh /var/lib/mysql
used=$(df -Ph / | awk 'NR == 2{print $5+0}')
if [ $used > 5 ]
then
    echo "The Mount Point "/DB" on $(hostname) has used $used at $(date)"
fi

#make the backup directory in the backup server node
echo $Enter yyyymmdd
read yyyymmdd
year=${yyyymmdd:0:4}
month=${yyyymmdd:4:2}
date=${yyyymmdd:6:2}
mkdir -p /home/sre/backups/$year/$month/$date

#rsync the backup file to the new directory created in the backup server node
/usr/bin/rsync  -amvP  --include="*"  -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i  /etc/backup_key -F /dev/null"  /local_mysql_backup/$year/$month/$date/* backup@stg-pymtsgalera006.phonepe.nb6:/pppool1/backups/PERMANENT_BACKUP/$year/$month/$date/`hostname -f`/

p=1
path=$1
port=7201
echo "Today's date?"
read D

#dockerup the backup file in the backup server node
while [ $p -lt 2 ]
do
STR="`ls -ltr /*/*/*backup* | grep -w "paymentsdb" | awk '{print $9}'`"
sh="`echo $STR |  awk -F'/' {'print $NF'} | cut -d':' -f1`"
DB="`echo $STR | cut -d'/' -f1,2,3,4,5,6,7,8,9`"
port="`echo 1+$port | bc`"
name="$D"_"$sh"
cmd="docker run --name $name -e MYSQL_ROOT_PASSWORD=ritwika -d -p $port:3306 -v /home/sre/backup:/var/lib/mysql mariadb:10.5.12"
echo $cmd
$cmd
p=`expr $p + 1`
done

#to check if the container is up and running
sleep 10m
stat=$(docker container ls | awk {'print $7'} | grep -i 'up')
min=$(docker container ls | awk {'print $8'} | grep '[0-9][0-9]')
str="Up"
if [ "$stat" == "$str" ]
then
    if [ "$min" > "9" ]
    then
        echo "Container is up and running"
    fi
else
    echo "error"
fi

#verify on the backup server node
monitoring='ritwika'
echo "Partition id:"
read pID1 pID2
for i in {1}
do
shard=`docker exec -it $name bin/bash -c "mysql -u root -p=$monitoring -e \"show databases;\" | grep paymentsdb"`
echo $shard
docker exec -it $name bin/bash -c "mysql -u root -p=$monitoring -Bs -e \"select partition_id,count(*) from $shard.data_flow_instances where partition_id in ($pID1,$pID2) group by partition_id; \""
done

#verification on async node
#/bin/bash
input=$1 #host_list
monitoring='Test@123'
echo "Partition id:"
read pID1 pID2
while IFS= read -r line
do
        echo "paymentsdb"
        mysql -u root -p=$monitoring -Bs -e "select partition_id,count(*) from paymentsdb.data_flow_instances where partition_id in ($pID1,$pID2) group by partition_id;"
done < "$input"


