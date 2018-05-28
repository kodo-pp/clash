#!/usr/bin/env false

declare -g __class__instances_count=0

# These are exceptions. Unfortunately there is no way of catching them, yet.
function raise() {
    echo "Exception raised, terminating" >&2
    echo "Exception text: $@" >&2
    __exception:backtrace
    kill $$
    exit 143
}

function __exception:backtrace() {
    {
        echo "Backtrace:"

        local cnt=2
        for i in "${FUNCNAME[@]}"; do
            case $cnt in
            0)
                echo "  Called from $i()"
                ;;
            1)
                cnt=0
                echo "  At $i()"
                ;;
            2)
                cnt=1
                ;;
            esac
        done
        echo
    } >&2
}

# And... Classes
function class() {
    classname="$1"
    __class:register_classname "$classname"
}

function regobj() {
    (( ++__class__instances_count ))
}

function objref() {
    echo -- "$1" | grep -Eo '^-- INSTANCE_ID=[0-9]+' | grep -Eo '[0-9]+'
}

function new() {
    classname="$1"
    shift

    if ! __class:defined "$classname"; then
        raise "Class $classname does not exist"
    fi

    obj_id=$(__class:instantiate "$classname")

    echo "INSTANCE_ID=$obj_id $classname"
}

function get_self() {
    echo "INSTANCE_ID=$1 prop"
}

function prop.set() {
    if ! __class:is_safe_identifier "$1"; then
        raise "Invalid property identifier"
    fi
    if ! __var_exist "__class__property_${INSTANCE_ID}_$1"; then
        declare -g "__class__property_${INSTANCE_ID}_$1"
    fi
    __var_set "__class__property_${INSTANCE_ID}_$1" "$2"
}

function prop.get() {
    if ! __class:is_safe_identifier "$1"; then
        raise "Invalid property identifier"
    fi

    if ! __var_exist "__class__property_${INSTANCE_ID}_$1"; then
        raise "Property '$1' is not initialized or does not exist"
    fi
    __var_get "__class__property_${INSTANCE_ID}_$1"
}

function prop.call() {
    eval "INSTANCE_ID=${INSTANCE_ID}" "$@"
}

function __class:defined() {
    if ! __class:is_safe_identifier "$1"; then
        raise "Invalid class identifier"
    fi
    if set | grep -q "^__class__classname_$1=yes\$"; then
        return 0
    else
        return 1
    fi
}

function __class:is_safe_identifier() {
    if [[ $1 =~ [A-Za-z_][A-Za-z_0-9]* ]]; then
        return 0
    else
        return 1
    fi
}

function __class:register_classname() {
    if __class:is_safe_identifier "$1"; then
        declare -g "__class__classname_$1"=yes
    else
        raise "Invalid class identifier"
    fi
}

function __class:instantiate() {
    classname="$1"
    if ! __class:defined "$classname"; then
        raise "Class $classname does not exist"
    fi

    echo $__class__instances_count
}

function __var_set() {
    declare -g $1="$2"
}

function __var_get() {
    eval "echo -- \"\$$1\" | tail -c +4"
}

function __var_exist() {
    if set | grep -q "^$1="; then
        return 0
    else
        return 1
    fi
}
