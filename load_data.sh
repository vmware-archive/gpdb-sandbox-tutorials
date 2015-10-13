-- Kill and restart the gpfdist utility on the database
ps ax | grep gpfdist
pkill -9 gpfdist
gpfdist -d /home/gpadmin/gpdb-sandboc-dayinthelife/ -p 8081 -l /home/gpadmin/gpdb-sandbox-dayinthelife/gpfdist.log &
gunzip 2008_cms_data.csv.gz


