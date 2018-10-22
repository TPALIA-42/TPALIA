:- dynamic one/1.
:- dynamic zero/1.

initassert :- assert(one((4,4))),
assert(one((5,5))),
assert(zero((5,4))),
assert(zero((4,5))),
assert(zero((3,5))),
assert(zero((2,5))),
assert(zero((6,4))),
assert(zero((7,4))),
assert(one((8,4))),
assert(one((3,6))).