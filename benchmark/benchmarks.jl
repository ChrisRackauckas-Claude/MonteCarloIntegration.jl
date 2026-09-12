using BenchmarkTools
using MonteCarloIntegration

const SUITE = BenchmarkGroup()

f_const(x) = 1
f_sum(x) = sum(x)
f_trig(x) = sum(sin.(x))
f_hard(x) = sin(x[1] + 3 * sin(2 * x[2] + 4 * sin(3 * x[3])))

batch_f(f) = pts -> map(f, pts)

SUITE["vegas"] = BenchmarkGroup()
for (name, f) in (
        ("constant", f_const), ("sum", f_sum), ("trig", f_trig),
    )
    for dim in (1, 3)
        SUITE["vegas"]["$(name)_d$(dim)"] = @benchmarkable vegas(
            $f, zeros($dim), ones($dim)
        )
    end
end
SUITE["vegas"]["hard_d3"] = @benchmarkable vegas($f_hard, zeros(3), fill(3.0, 3); maxiter = 50)

SUITE["vegas_batch"] = BenchmarkGroup()
for (name, f) in (("sum", f_sum), ("trig", f_trig))
    SUITE["vegas_batch"]["$(name)_d3"] = @benchmarkable vegas(
        $(batch_f(f)), zeros(3), ones(3); batch = true
    )
end
