#!/usr/bin/env bash
. class.sh

class Vector

function Vector.Vector() {
    local self="$(get_self $INSTANCE_ID)"
    eval $self.set x "$1"
    eval $self.set y "$2"
}

function Vector.add() {
    local self="$(get_self $INSTANCE_ID)"
    local other="$(get_self $1)"

    local x=$(( $(eval $self.get x) + $(eval $other.get x) ))
    local y=$(( $(eval $self.get y) + $(eval $other.get y) ))

    eval $self.call Vector.Vector $x $y
}

function Vector.multiply_num() {
    local self="$(get_self $INSTANCE_ID)"
    local x=$(( $(eval $self.get x) * $1 ))
    local y=$(( $(eval $self.get y) * $1 ))

    eval $self.call Vector.Vector $x $y
}

function Vector.multiply_vec() {
    local self="$(get_self $INSTANCE_ID)"
    local other="$(get_self $1)"

    local xx=$(( $(eval $self.get x) * $(eval $other.get x) ))
    local yy=$(( $(eval $self.get y) * $(eval $other.get y) ))
    echo $(( $xx + $yy ))
}

function Vector.print() {
    local self="$(get_self $INSTANCE_ID)"
    local x=$(eval $self.get x)
    local y=$(eval $self.get y)
    echo "vector2($x, $y)"
}

function main() {
    local vec1=$(new Vector); regobj
    local vec2=$(new Vector); regobj

    eval $vec1.Vector 2 7
    eval $vec2.Vector -5 1

    eval $vec1.print
    eval $vec2.print

    local vec2r=$(objref "$vec2")
    mult=$(eval $vec1.multiply_vec $vec2r)

    echo $mult

    eval $vec1.print
    eval $vec2.print
}

main
