update:
    julia --project=. -e 'import Pkg; Pkg.update()'
    julia --project=.ci -e 'import Pkg; Pkg.update()'

fmt:
    runic --inplace .

fmt-check:
    runic --check .

changelog:
    julia --project=.ci .ci/changelog.jl

test:
    julia --project=. -e 'import Pkg; Pkg.test()'

docs:
    julia --project=docs -e 'import Pkg; Pkg.instantiate(); include("docs/make.jl")'
