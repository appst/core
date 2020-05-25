:<<\_c
. $PICASSO/core/bin/openstack-client.fun
_c

. $PICASSO/core/bin/consul.fun

#_kv_get_file openrc > $PWORK/$PID/.picasso/bin/openrc && chmod 644 $PWORK/$PID/.picasso/bin/openrc
_kv_get_file openrc $PWORK/$PID/.picasso/bin/openrc && chmod 644 $PWORK/$PID/.picasso/bin/openrc

:<<\_x
which openrc  # /mnt/proot/bin/openrc

PATH=$PWORK/$PID/.picasso/bin:$PATH
which openrc  # $PWORK/$PID/.picasso/bin/openrc
_x

