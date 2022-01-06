% Pick a 2-tuple with values in the range {0,1}

include "table.mzn";

array [1..2] of var 0..1: tup;

constraint table(tup, [|0,0|0,1|1,0|1,1|]);