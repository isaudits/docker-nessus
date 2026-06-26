#!/command/with-contenv bash

set -e

username=${1:?username is required}
password=${2:?password is required}
max_attempts=${NESSUS_ADDUSER_RETRIES:-60}
retry_delay=${NESSUS_ADDUSER_RETRY_DELAY:-10}

attempt=1
while [ "${attempt}" -le "${max_attempts}" ]; do
    set +e
    users_output=$(/opt/nessus/sbin/nessuscli lsuser 2>&1)
    users_rc=$?
    set -e

    if [ "${users_rc}" -eq 0 ] && printf "%s\n" "${users_output}" | grep -Fxq -- "${username}"; then
        printf "\n-- Nessus user %s already exists\n" "${username}"
        exit 0
    fi

    set +e
    adduser_output=$(printf "%s\n%s\ny\n\ny\n" "${password}" "${password}" | \
        /opt/nessus/sbin/nessuscli adduser "${username}" 2>&1)
    adduser_rc=$?
    set -e

    if [ "${adduser_rc}" -eq 0 ]; then
        printf "\n-- Nessus user %s created\n" "${username}"
        exit 0
    fi

    if ! printf "%s\n%s\n" "${users_output}" "${adduser_output}" | grep -Fq "global.db is not ready yet"; then
        printf "\n%s\n" "${adduser_output}"
        exit "${adduser_rc}"
    fi

    if [ "${attempt}" -lt "${max_attempts}" ]; then
        printf "\n-- Nessus database is not ready yet; retrying user creation in %ss (%s/%s)\n" "${retry_delay}" "${attempt}" "${max_attempts}"
        sleep "${retry_delay}"
    fi

    attempt=$((attempt + 1))
done

printf "\n-- Nessus database did not become ready after %s attempts\n" "${max_attempts}"
exit 1
