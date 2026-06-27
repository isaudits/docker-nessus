#!/command/with-contenv bash

set -o pipefail

LOCK_DIR=/tmp/update-nessus.lock
LOG_FILE=${UPDATE_NESSUS_LOG_FILE:-/var/log/update_nessus.log}
STDOUT_ENABLED=true

timestamp() {
    date '+%Y-%m-%d %H:%M:%S %Z'
}

log() {
    printf '[%s] %s\n' "$(timestamp)" "$*" >> "${LOG_FILE}"
}

stdout() {
    if [ "${STDOUT_ENABLED}" = true ]; then
        printf '%s\n' "$*"
    fi
}

run_logged() {
    log "Running: $*"
    stdout "Running: $*"

    "$@" 2>&1 | tr '\r' '\n' | while IFS= read -r line; do
        if [ -n "${line}" ]; then
            log "${line}"
            stdout "${line}"
        fi
    done

    return "${PIPESTATUS[0]}"
}

cleanup() {
    rmdir "${LOCK_DIR}" 2>/dev/null || true
}

stdout_target=$(readlink /proc/$$/fd/1 2>/dev/null || true)
if [ "${stdout_target}" = "${LOG_FILE}" ]; then
    STDOUT_ENABLED=false
fi

if ! mkdir "${LOCK_DIR}" 2>/dev/null; then
    log "Another Nessus update is already running; skipping this run"
    stdout "Another Nessus update is already running; skipping this run"
    exit 0
fi

trap cleanup EXIT

log "========== Nessus update started =========="
log "Timezone: ${TZ:-$(date +%Z)}"
stdout "Nessus update started"

exit_code=0

# Check registration status and update
if run_logged /opt/nessus/sbin/nessuscli fetch --check; then
    run_logged /opt/nessus/sbin/nessuscli update --all || exit_code=$?
elif [ -n "${LICENSE}" ]; then
    log "Registering as a Nessus Pro scanner and downloading updates"
    stdout "Registering as a Nessus Pro scanner and downloading updates"
    run_logged /opt/nessus/sbin/nessuscli fetch --register "${LICENSE}" || exit_code=$?
    if [ "${exit_code}" -eq 0 ]; then
        run_logged /opt/nessus/sbin/nessuscli update --all || exit_code=$?
    fi
elif [ -n "${SECURITYCENTER}" ]; then
    log "Registering as a SecurityCenter-linked scanner and downloading updates"
    stdout "Registering as a SecurityCenter-linked scanner and downloading updates"
    run_logged /opt/nessus/sbin/nessuscli fetch --security-center || exit_code=$?
    if [ "${exit_code}" -eq 0 ]; then
        run_logged /opt/nessus/sbin/nessuscli update --all || exit_code=$?
    fi
else
    log "Nessus registration check failed and no LICENSE or SECURITYCENTER setting is configured"
    stdout "Nessus registration check failed and no LICENSE or SECURITYCENTER setting is configured"
    exit_code=1
fi

if [ "${exit_code}" -eq 0 ]; then
    log "========== Nessus update finished successfully =========="
    stdout "Nessus update finished successfully"
else
    log "========== Nessus update failed with exit code ${exit_code} =========="
    stdout "Nessus update failed with exit code ${exit_code}"
fi

exit "${exit_code}"
