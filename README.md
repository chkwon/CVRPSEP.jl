# CVRPSEP.jl

[![Build Status](https://github.com/chkwon/CVRPSEP.jl/workflows/CI/badge.svg?branch=master)](https://github.com/chkwon/CVRPSEP.jl/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/chkwon/CVRPSEP.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/chkwon/CVRPSEP.jl)


**License:** 
The original [CVRPSEP](https://econ.au.dk/research/researcher-websites/jens-lysgaard/cvrpsep/), which is distributed under the [CPL v1.0 License](https://github.com/chkwon/CVRPSEP/blob/main/LICENSE). 
However, this Julia package is distributed under the [MIT License](https://github.com/chkwon/CVRPSEP.jl/blob/master/LICENSE).
Note that this Julia package uses [a minor modificiation](https://github.com/chkwon/CVRPSEP) of the original CVRPSEP library.

To install:
```julia
] add https://github.com/chkwon/CVRPSEP.jl.git
```


**NOTE:**
This code is a work in progress. Currently `rounded_capacity_cuts!()`, `strengthened_comb_inequalities!()`, `framed_capacity_inequalities!()`, `hypotour_inequalities!()`, `multistar_inequalities!()` exist, but not tested sufficiently. PRs are welcome.
