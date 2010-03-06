#! /bin/sh
### BEGIN INIT INFO
# Provides:          aiccu
# Required-Start:    $local_fs $remote_fs $syslog $network $time $named
# Required-Stop:     $local_fs $remote_fs $syslog $network $time $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: SixXS Automatic IPv6 Connectivity Client Utility
# Description:
#   This client configures IPv6 connectivity without having to 
#   manually configure interfaces etc. A SixXS account or an account
#   of another supported tunnel broker and at least one tunnel are
#   required. These can be freely requested from the SixXS website
#   at no cost. For more information about SixXS check their homepage.
### END INIT INFO

# Original Author: Jeroen Massar <jeroen@sixxs.net>
# Author: Reinier Haasjes <reinier@haasjes.com>
#

# Do NOT "set -e"

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="SixXS Automatic IPv6 Connectivity Client Utility"
NAME=aiccu
DAEMON=/usr/sbin/$NAME
DAEMON_ARGS=""
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

# Is aiccu enabled?
case "$AICCU_ENABLED" in
  [Nn]*)
        exit 0
        ;;
esac

#
# Function that starts the daemon/service
#
do_start()
{
	# Verify that the configuration file exists
	if [ ! -f /etc/aiccu.conf ]; then
	        log_failure_msg "AICCU Configuration file /etc/aiccu.conf doesn't exist"
	        exit 1;
	fi
	
	# Verify that the configuration is correct
	if [ `grep -c "^username" /etc/aiccu.conf 2>/dev/null` -ne 1 ]; then
	        log_failure_msg "AICCU is not configured, edit /etc/aiccu.conf first"
	        exit 1;
	fi
	
	# Verify that it is in daemonize mode, otherwise it won't ever return
	if [ `grep -c "^daemonize true" /etc/aiccu.conf 2>/dev/null` -ne 1 ]; then
	        log_failure_msg "AICCU is not configured to daemonize on run"
	        exit 1;
	fi

	# Return
	#   0 if daemon has been started
	#   1 if daemon was already running
	#   2 if daemon could not be started
	start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON --test > /dev/null \
		|| return 1
	start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON -- start \
		$DAEMON_ARGS \
		|| return 2
	# Add code here, if necessary, that waits for the process to be ready
	# to handle requests from services started subsequently which depend
	# on this one.  As a last resort, sleep for some time.
}

#
# Function that stops the daemon/service
#
do_stop()
{
	# Return
	#   0 if daemon has been stopped
	#   1 if daemon was already stopped
	#   2 if daemon could not be stopped
	#   other if a failure occurred
	start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile $PIDFILE --name $NAME
	RETVAL="$?"
	[ "$RETVAL" = 2 ] && return 2
	# Wait for children to finish too if this is a daemon that forks
	# and if the daemon is only ever run from this initscript.
	# If the above conditions are not satisfied then add some other code
	# that waits for the process to drop all resources that could be
	# needed by services started subsequently.  A last resort is to
	# sleep for some time.
	start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec $DAEMON -- stop
	[ "$?" = 2 ] && return 2
	# Many daemons don't delete their pidfiles when they exit.
	rm -f $PIDFILE
	return "$RETVAL"
}

case "$1" in
  start)
	[ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
	do_start
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  stop)
	[ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
	do_stop
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  status)
       status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
       ;;
  restart|force-reload)
	#
	# If the "reload" option is implemented then remove the
	# 'force-reload' alias
	#
	log_daemon_msg "Restarting $DESC" "$NAME"
	do_stop
	case "$?" in
	  0|1)
		do_start
		case "$?" in
			0) log_end_msg 0 ;;
			1) log_end_msg 1 ;; # Old process is still running
			*) log_end_msg 1 ;; # Failed to start
		esac
		;;
	  *)
	  	# Failed to stop
		log_end_msg 1
		;;
	esac
	;;
  *)
	echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
	exit 3
	;;
esac

:
