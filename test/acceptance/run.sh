#!/usr/bin/env bash

function cleanup() {
    echo 'cleaning up'
    cd /tmp/acceptance/lambda-handlers/
    serverless remove --runtime ${runtime} --runtimeName ${runtimeName} --buildNumber ${build_num}
    cd $INITIAL_PWD
    rm -rf /tmp/acceptance
}

trap clenaup 1 2 15

function run_acceptance_test() {
    build_num=$1
    runtime=$2
    runtimeName=$3
    echo "deploying of ${runtime} [build: ${build_num}]"
    cp -r test/acceptance/ /tmp/acceptance/
    cd /tmp/acceptance/lambda-handlers/
    npm install $INITIAL_PWD
    serverless deploy --runtime ${runtime} --runtimeName ${runtimeName} --buildNumber ${build_num} || {  echo "deployment of ${runtime} [build: ${build_num}] failed" ; result=1; }
    cd -
    TRAVIS_BUILD_NUMBER=${build_num} RUNTIME=${runtime} RUNTIME_NAME=${runtimeName} mocha -t 30000 test/acceptance/acceptance.js || {  echo "tests ${runtime} [build: ${build_num}] failed" ; result=1; }
    cleanup
}

INITIAL_PWD=`pwd`
build_num=$1
result=0

run_acceptance_test ${build_num} nodejs10.x njs10
run_acceptance_test ${build_num} nodejs8.10 njs8

exit ${result}
