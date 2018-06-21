declare -Ag __exception__handlers
declare -g __exception__ecode=SUCCESS

__RAISE_STACK_LIMIT=1000

function raise() {
    local exccode="$1"
    shift
    if [ ".$exccode" != ".EFATAL" -a ${#FUNCNAME[@]} -gt $__RAISE_STACK_LIMIT ]; then
        raise EFATAL "Stack limit exceeded for raise"
    fi
    if [ ".${__exception__handlers[$exccode]}" == "." ]; then
        __exception:terminate "$exccode" "$@"
    else
        local handler=${__exception__handlers[$exccode]}
        __exception__ecode="$exccode"
        if ! "$handler" "$exccode"; then
            echo "Exception '$exccode' raised" >&2
            echo "Exception text: $@" >&2
            echo "Exception handler failed to handle this exception, so another exception was raised" >&2
            echo >&2
            raise EFATAL 'Exception handling failed'
        fi
    fi
}

function catch() {
    if [ ".$1" != ".EFATAL" ]; then
        __exception__handlers["$1"]="$2"
    else
        raise EFATAL "EFATAL exception cannot be caught"
    fi
}

function clear_ecode() {
    __exception__ecode=SUCCESS
}

function get_ecode() {
    echo $__exception__ecode
}

function __exception:terminate() {
    echo "Exception '$1' raised, terminating" >&2
    shift
    echo "Exception text: $@" >&2
    __exception:backtrace
    kill $$
    exit 143
}

function __exception:backtrace() {
    {
        echo "Backtrace:"

        local cnt=1
        for i in "${FUNCNAME[@]}"; do
            case $cnt in
            0)
                echo "  Called from $i()"
                ;;
            1)
                cnt=0
                echo "  At          $i()"
                ;;
            esac
        done
        echo
    } >&2
}
