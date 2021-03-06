include ../deploy/Makefile.vars

${ROOT_DIR}/var/db/base: ${ROOT_DIR}/var
	install -m 700 -d ${ROOT_DIR}/var/db/
	[ -e  ${ROOT_DIR}/var/db/base ] || initdb --username=postgres ${ROOT_DIR}/var/db/
	touch ${ROOT_DIR}/var/db/base

runpg: ${POSTGRES} ${ROOT_DIR}/var/db/base ${ROOT_DIR}/run
	${POSTGRES} -D ${ROOT_DIR}/var/db/ -c log_destination=stderr -c unix_socket_directories=${ROOT_DIR}/run/ &

createdb: ${ROOT_DIR}/var/db/postmaster.pid
	psql -l --username=postgres --no-password --host=127.0.0.1 | grep billing || \
	(createdb --username=postgres --no-password --host=127.0.0.1 billing && \
	echo CREATE EXTENSION hstore | psql -d billing --username=postgres --no-password --host=127.0.0.1 \
	)

stoppg: ${ROOT_DIR}/var/db/postmaster.pid
	kill `head -n 1 ${ROOT_DIR}/var/db/postmaster.pid`



