#!/usr/bin/env bash
. exception.sh

function foo() {
    echo foo
    bar 3
    bar 5
    baz
}

function bar() {
    echo "bar($1)"
    if [ "$1" -gt 0 ]; then
        bar $(( $1 - 1 ))
    else
        baz
    fi
}

function baz() {
    echo baz
    raise EXCEPTION_TEST 'Some text'
}

function handler() {
    echo "HANDLER: $@"
}

function handler2() {
    echo a
}

#catch EXCEPTION_TEST handler
foo
