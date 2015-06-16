[![PullReview stats](https://www.pullreview.com/github/toch/benchmark-lab/badges/master.svg?)](https://www.pullreview.com/github/toch/benchmark-lab/reviews/master)

# Benchmark Lab

Run Real Experiment and Calculate Non-Parametric Statistics.

## Installation

Install it yourself as:

    $ gem install benchmark-lab

## Usage

There are two ways to use it:
1. classic: as Benchmark.bm does
2. iterative: collects and measures separately, stores into different JSON
files, then put everything together and rank them

### Classic Usage

```Ruby
require 'benchmark/lab'

n = 5_000_000
cases = {
  'for:'    => proc { for i in 1..n; a = "1"; end },
  'times:'  => proc { n.times do   ; a = "1"; end },
  'upto:'   => proc { 1.upto(n) do ; a = "1"; end }
}

# How many times do you run the function
# 20 is a good minimum number
nbr_of_samples = 20

Benchmark.experiment(nbr_of_samples) do |x|
  cases.each { |label, blk| x.report(label, &blk) }
end
```

The output looks like the following:
```
          user                system              total               real
for:      [0.77,0.77,0.78]    [0.00,0.00,0.00]    [0.77,0.77,0.78]    [0.77,0.77,0.78]
times:    [0.74,0.74,0.74]    [0.00,0.00,0.00]    [0.74,0.74,0.74]    [0.74,0.74,0.74]
upto:     [0.75,0.75,0.75]    [0.00,0.00,0.00]    [0.75,0.75,0.75]    [0.75,0.75,0.75]
The best "times:" is significantly (95%) better (total time).
```

### Iterative Usage

```Ruby
require 'benchmark/lab'

n = 5_000_000

# How many times do you run the function
# 20 is a good minimum number
nbr_of_samples = 20

jsons = []

jsons << Benchmark.observe_and_summarize(nbr_of_samples) do |x|
  x.report('for') { for i in 1..n; a = "1"; end }
end

jsons << Benchmark.observe_and_summarize(nbr_of_samples) do |x|
  x.report('times') { n.times do   ; a = "1"; end }
end

jsons << Benchmark.observe_and_summarize(nbr_of_samples) do |x|
  x.report('upto') { 1.upto(n) do ; a = "1"; end }
end

best, is_h0_rejected = Benchmark.aggregate_and_rank(jsons.map { |json| JSON.parse(json) })

puts best
puts is_h0_rejected
```

The output looks like the following:
```
{"name"=>"total", "sample"=>[0.6899999999999977, 0.6899999999999977, 0.6899999999999977, 0.6899999999999977, 0.6900000000000013, 0.6900000000000048, 0.6900000000000048, 0.6999999999999957, 0.6999999999999957, 0.6999999999999957, 0.6999999999999957, 0.6999999999999957, 0.6999999999999993, 0.6999999999999993, 0.7000000000000028, 0.7000000000000028, 0.7000000000000028, 0.7000000000000028, 0.7000000000000028, 0.7000000000000028], "sample_size"=>20, "minimum"=>0.6899999999999977, "maximum"=>0.7000000000000028, "first_quartile"=>0.690000000000003, "third_quartile"=>0.7000000000000028, "median"=>0.6999999999999957, "interquartile_range"=>0.009999999999999787, "label"=>"upto"}
true
```

## Ideas

* compare two different implementations of a same function
  1. get the stats, then compare
  2. use git (commit, branch)
  3. use tests to check no performance regression at the same time
  4. annotate the tests you want to check
* decide the sample size automatically (based on the power you want to reach)
* explain correctly why we should do that

## Contributing

1. Fork it ( https://github.com/toch/benchmark-lab/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
