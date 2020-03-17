#!/bin/bash -x
set -e
_js_escape() {
        jq --null-input --arg 'str' "$1" '$str'
}
# a default non-root role
MONGO_NON_ROOT_ROLE="${MONGO_NON_ROOT_ROLE:-readWrite}"
mongo=( mongo --host 127.0.0.1 --port 27017 --quiet )

if [ -n "${MONGO_NON_ROOT_USERNAME:-}" ] && [ -n "${MONGO_NON_ROOT_PASSWORD:-}" ]; then
  echo "Configuring database: "$MONGO_INITDB_DATABASE" for user: "$MONGO_NON_ROOT_USERNAME
	"${mongo[@]}" "$MONGO_INITDB_DATABASE" <<-EOJS
    use $MONGO_INITDB_DATABASE
		db.createUser({
			user: $(_js_escape "$MONGO_NON_ROOT_USERNAME"),
			pwd: $(_js_escape "$MONGO_NON_ROOT_PASSWORD"),
			roles: [ {role: $(_js_escape "$MONGO_NON_ROOT_ROLE"), db: $(_js_escape "$MONGO_INITDB_DATABASE") } ]
			})
	EOJS
else
  echo "WARNING: Not Initializing database"
	# print warning or kill temporary mongo and exit non-zero
fi
