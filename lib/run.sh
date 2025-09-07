#!/bin/sh

. $LKP_SRC/lib/debug.sh
. $LKP_SRC/lib/reproduce-log.sh

cd_benchmark()
{
	local suite=${1:-$suite}

	[ -n "$suite" ] || die "suite argument is empty"

	log_cmd cd $BENCHMARK_ROOT/$suite || die "$BENCHMARK_ROOT/$suite does not exist"
}

report_ops()
{
	stop_time=$(date +%s)
	echo "ops: $operations, ops/sec: $(echo "x = $operations / ($stop_time - $start_time); if (x < 1) print 0; x" | bc -l)"
	exit
}

test_loop()
{
	trap report_ops HUP

	start_time=$(date +%s)
	operations=0

	while :
	do
		do_test
		operations=$((operations + 1))
	done
}

runtime_loop()
{
	test_loop &
	local pid="$!"
	sleep $runtime
	kill -s HUP $pid
	wait
}
