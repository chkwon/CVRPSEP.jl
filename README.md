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

**Current Status**
This code is a work in progress.

- Rounded Capacity Inequalities: `rounded_capacity_cuts!()`, well tested
- Homogeneous multistart inequalities: `multistar_inequalities!()`, reasonably tested
- Generalized large multistar inequalities: not yet
- Framed capacity inequalities: `framed_capacity_inequalities!()`, reasonably tested
- Strengthened comb inequalities: `strengthened_comb_inequalities!()`, reasonably tested
- Hypotour inequalities: `hypotour_inequalities!()`, failing. Needs debugging and testing.

PRs are welcome for testing, developing, implementing, or improving.