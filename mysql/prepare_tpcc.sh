#!/bin/sh

# Configure to match your host system
OLTPBENCH=$HOME/Downloads/oltpbench
OLTPBENCH_CONFIG=$HOME/utils/sample_tpcc_config.xml

DATAPATH=$PWD/install/usr/data
BASEPATH=$PWD/install/usr

if [ -d "$HOME/osv-tpcc-data" ]
then
	# Use existing database copy to save time
	rm -r $DATAPATH
	cp -r "$HOME/osv-tpcc-data" $DATAPATH
else

	# Start a MySQL server to create the TPCC database using the benchmark
	# client
	cat > osv-mysql.cnf <<EOF
[mysqld]
datadir=$DATAPATH
basedir=$BASEPATH
socket=$PWD/osv-mysql.sock
bind-address=0.0.0.0
EOF

	sleep 8

	$BASEPATH/bin/mysqld --defaults-file=$PWD/osv-mysql.cnf &

	sleep 5

	cd $OLTPBENCH

	echo "create database tpcc" | mysql -u root -h 127.0.0.1
	./oltpbenchmark -b tpcc -c $OLTPBENCH_CONFIG --create=true --load=true

	killall mysqld
	wait
fi

