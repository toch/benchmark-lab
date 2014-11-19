require_relative '../spec_helper'

describe Benchmark::Experiment do
  let(:cases) do
    n = 5000000
    {
      'for:'    => proc { for i in 1..n; a = "1"; end },
      'times:'  => proc { n.times do   ; a = "1"; end },
      'upto:'   => proc { 1.upto(n) do ; a = "1"; end }
    }
  end

  it 'prints a report for each run case.' do
    output_arr = []
    output_arr << %r{\s+user\s+system\s+total\s+real\s+\n}

    cases.keys.each do |label|
      output_arr << %r{#{label}}
      4.times.each do
        output_arr << %r{\s+\[\d+\.\d+,\d+\.\d+,\d+\.\d+\]}
      end
      output_arr << %r{\n}
    end

    output_regexp = output_arr.inject(//) { |o, r| Regexp.new(o.source + r.source) }

    times = 2
    proc do
      Benchmark.experiment(times) do |x|
        cases.each { |label, blk| x.report(label, &blk) }
      end
    end.must_output output_regexp
  end

  it 'returns an array with stats for each run case.' do
    times = 20
    results = Benchmark.experiment(times) do |x|
      cases.each { |label, blk| x.report(label, &blk) }
    end

    results.size.must_equal 3
    # results.map(&:label).must_equal cases.keys
  end
end