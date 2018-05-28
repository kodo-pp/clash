#!/usr/bin/env bash

. /usr/lib/cla.sh

class Point

Point.Point() {
    self=$(get_self $INSTANCE_ID)
    eval $self.set 'x' "$1"
    eval $self.set 'y' "$2"
}

Point.print() {
    self=$(get_self $INSTANCE_ID)
    echo "($(eval $self.get x), $(eval $self.get y))"
}

Point.add() {
    self=$(get_self $INSTANCE_ID)
    other=$(get_self $1)

    eval $self.call Point.Point "$[ $(eval $self.get x) + $(eval $other.get x) ]" \
                                "$[ $(eval $self.get y) + $(eval $other.get y) ]"
}

echo "Creating points"
p1=$(new Point); regobj
p2=$(new Point); regobj

echo "Constructing points"
eval $p1.Point 6 8
eval $p2.Point 3 9

echo "Values of points:"
eval $p1.print
eval $p2.print

echo "Adding points"
p2ref=$(objref "$p2")
eval $p1.add $p2ref

echo "Values of points after addition:"
eval $p1.print
eval $p2.print
