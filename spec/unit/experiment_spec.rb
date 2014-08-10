require_relative '../spec_helper'

describe Benchmark::Experiment do
  let(:cases) do
    {
      'for:'    => proc { for i in 1..n; a = "1"; end },
      'times:'  => proc { n.times do   ; a = "1"; end },
      'upto:'   => proc { 1.upto(n) do ; a = "1"; end }
    }
  end

  it 'prints a report for each run case.' do
    output_arr = []
    output_arr << %r{
      ^\s+user\s+system\s+total\s+real$
    }

    number = /\d+\.\d+/
    box_plot = /\[#{number},#{number},#{number}\]/
    
    cases.keys.each do |label|
      output_arr << %r{
        ^#{label}\s+#{box_plot}\s+#{box_plot}\s+#{box_plot}\s+#{box_plot}$
      }
    end

    output_regexp = Regexp.new(output_arr.inject('') { |str, r| str << r.to_s })

    n = 5000000
    times = 2
    proc do
      Benchmark.experiment(times) do |x|
        cases.each { |label, blk| x.case(label, &blk) }
      end
    end.must_output output_regexp
  end

  it 'returns an array with stats for each run case.' do
    n = 5000000
    times = 2
    results = Benchmark.experiment(times) do |x|
      cases.each { |label, blk| x.case(label, &blk) }
    end

    results.size.must_equal 3
    results.map(&:label).must_equal cases.keys
  end
end