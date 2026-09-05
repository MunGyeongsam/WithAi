local Metrics = { counts = {} }

function Metrics.increment(name)
    Metrics.counts[name] = (Metrics.counts[name] or 0) + 1
end

function Metrics.read(name)
    return Metrics.counts[name] or 0
end

local gameplay_metrics = Metrics
gameplay_metrics.increment("ball_hits")
Metrics.increment("ball_hits")

assert(gameplay_metrics == Metrics and Metrics.read("ball_hits") == 2)
print(Metrics.read("ball_hits"))
