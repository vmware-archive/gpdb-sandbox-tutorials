-- Kill and restart the gpfdist utility on the database
ps ax | grep gpfdist
pkill -9 gpfdist
gpfdist -d /home/gpadmin/gpdb-sandbox-tutorials/ -p 8081 -l /home/gpadmin/gpdb-sandbox-tutorials/gpfdist.log &


