#!/usr/bin/env bash -x

if [ "$#" -eq "2" ] || [ "$#" -eq "3" ]; then
    echo "run: `basename $0` $*"
    echo $#
else
    echo "Usage: `basename $0` rtm-aar 1.0.0 [bintray key]"
    exit 1
fi

product=$1
sdk_version=$2
echo $0

if [ "$#" -eq "3" ]; then
    export BINTRAY_KEY=$3
fi
export PUBLISH_SDK_VERSION=${sdk_version}
echo product: $1, sdk_version: $2
echo $PUBLISH_SDK_VERSION
#source ~/.bash_profile

# ----------- #
# function    #
# ----------- #
die() {
    echo
    echo "$*"
    echo
    exit 1
}

echo_stdout() {
    while IFS='' read -r line || [[ -n "$line" ]]; do
        echo ${line}
    done < release.log
}

echo_run() {
    echo
    echo "$*"
    echo "$*" >> release.log
    `$* >> release.log`
    echo
    echo_stdout
    grep 'FAILED' release.log
#    if [ ! -n  $(grep 'FAILED' release.log) ]; then
#        die "catch failure!"
#    fi
}


# -------- #
# build    #
# -------- #
# clear log file
if [ -e release.log ]; then
    echo_run rm -f release.log
fi

echo_run ./gradlew ${product}:clean
echo_run ./gradlew ${product}:assembleRelease


# -------- #
# upload   #
# -------- #
echo_run ./gradlew ${product}:bintrayUpload -PbintrayUser=agora -PbintrayKey=${BINTRAY_KEY} -PdryRun=false


# -------- #
# teardown #
# -------- #
#git clean -xdf

exit 0
