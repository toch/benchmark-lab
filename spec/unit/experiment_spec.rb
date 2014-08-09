require_relative '../spec_helper'

describe Benchmark::Experiment do
  it 'tests' do
    n = 5000000
    times = 2
    results = Benchmark.experiment(times) do |x|
      x.case("for:")   { for i in 1..n; a = "1"; end }
      x.case("times:") { n.times do   ; a = "1"; end }
      x.case("upto:")  { 1.upto(n) do ; a = "1"; end }
    end

    results.size.must_equal 3
  end
end