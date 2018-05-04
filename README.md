# rosette-experiments
Simple programs trying out features of [Rosette](https://emina.github.io/rosette/), a solver-aided programming language.

- operationCombination.rkt : given three possible operations (add-2(x), add-3(x) and add(x, y) ), generating a program of maximal depth `d` that achieves the final goal. an example of interpreter-base (deep) embedding of a language into Rosette, as described [here](https://homes.cs.washington.edu/~emina/pubs/rosette.onward13.pdf)

- lineMover.rkt : a language consisting of two operations, -> x (go right x steps) and <- (go left x steps). Solver needs to synthesize a two-step program and the initial position leading to a goal `g`
