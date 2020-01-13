#!/usr/bin/env sh

# Copyright (c) 2018 Philippe Pepiot <phil@philpep.org>
# The MIT License (MIT)
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

if [ -f /.dockerenv ]; then
    if [ -x /sbin/apk ]; then
        apk upgrade --no-cache --simulate | grep 'Upgrading' && exit 1
    elif [ -x /usr/bin/apt-get ]; then
        apt-get update > /dev/null 2>&1
        apt list --upgradable 2>/dev/null | grep 'upgradable from' && exit 1
    elif [ -x /usr/bin/dnf ]; then
        dnf -q check-update || exit $?
    elif [ -x /usr/bin/yum ]; then
        yum check-update -q || exit $?
    fi
    exit 0
fi

if [ -z "${1}" ]; then
    >&2 echo "${0} requires docker image name as argument"
    exit 64
fi

>&2 echo "INFO: Checking if packages in ${1} are up-to-date"
if docker run --rm --entrypoint /bin/sh -u root -v "$(readlink -f "${0}")":/check_update.sh "${1}" /check_update.sh; then
    >&2 echo "INFO: Packages in ${1} are up-to-date"
else
    >&2 echo "WARNING: Packages in ${1} are outdated" && exit 1
fi