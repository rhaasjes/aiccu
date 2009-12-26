#! /bin/sh
#
# /etc/init.d/aiccu: start / stop AICCU
#
# Jeroen Massar <jeroen@sixxs.net>
exit 0

### BEGIN INIT INFO
# Provides: aiccu
# Required-Start: $local_fs $remote_fs $network $time $named
# Required-Stop: $local_fs $remote_fs $network $time $named
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: SixXS Automatic IPv6 Connectivity Client Utility
# Description:
#   This client configures IPv6 connectivity without having to 
#   manually configure interfaces etc. A SixXS account or an account
#   of another supported tunnel broker and at least one tunnel are
#   required. These can be freely requested from the SixXS website
#   at no cost. For more information about SixXS check their homepage.
### END INIT INFO

PATH=/sbin:/bin:/usr/sbin:/usr/bin
NAME=aiccu
DAEMON=/usr/sbin/${NAME}
DESC="SixXS Automatic IPv6 Connectivity Client Utility (${NAME})"
BACKGROUND=true

# Options
OPTIONS=""

test -x $DAEMON || exit 0

. /lib/lsb/init-functions

if [ -f /etc/default/${NAME} ]; then
	. /etc/default/${NAME}
fi

# Verify that the configuration file exists
if [ ! -f /etc/aiccu.conf ]; then
	echo "AICCU Configuration file /etc/aiccu.conf doesn't exist"
	exit 0;
fi

# Verify that the configuration is correct
if [ `grep -c "^username" /etc/aiccu.conf 2>/dev/null` -ne 1 ]; then
	echo "AICCU is not configured, edit /etc/aiccu.conf first"
	exit 0;
fi

# Verify that it is in daemonize mode, otherwise it won't ever return
if [ `grep -c "^daemonize true" /etc/aiccu.conf 2>/dev/null` -ne 1 ]; then
	echo "AICCU is not configured to daemonize on run"
	exit 0;
fi

if [ "$BACKGROUND" = "false" ]; then
	exit 0;
fi

case "$1" in
  start)
	log_begin_msg "Starting $DESC..."
	start-stop-daemon --start --oknodo --quiet --exec $DAEMON -- start $OPTIONS
	log_end_msg $?
	;;
  stop)
	log_begin_msg "Stopping $DESC..."
	start-stop-daemon --stop --oknodo --quiet --exec $DAEMON -- stop
	log_end_msg $?
	;;
  restart|reload|force-reload)
	log_begin_msg "Restarting $DESC..."
	start-stop-daemon --stop --oknodo --quiet --exec $DAEMON -- stop
	sleep 2
	start-stop-daemon --start --oknodo --quiet --exec $DAEMON -- start $OPTIONS
	log_end_msg $?
	;;
  *)
	echo "Usage: /etc/init.d/$NAME {start|stop|reload|force-reload|restart}" >&2
	exit 1
esac

exit 0
