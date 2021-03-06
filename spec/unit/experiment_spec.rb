require_relative '../spec_helper'

describe Benchmark::Experiment do
  let(:cases) do
    n = 5_000_000
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
    results.map{ |label, _| label}.must_equal cases.keys
  end

  it 'collects and stores the descriptive statistics into a JSON' do
    times = 2
    result = Benchmark.observe_and_summarize(times) do |x|
      cases.each { |label, blk| x.report(label, &blk) }
    end

    items = JSON.parse(result)
    items.size.must_equal 3
    items['for:'].first['name'].must_equal 'utime'
  end

  it 'aggregates several benchmark results and ranks them' do
    stat_one = {
      'first' => [
        {
          'name' => 'total',
          'median' => 10,
          'sample' => [10] * 20
        }
      ]
    }
    stat_two = {
      'second' => [
        {
          'name' => 'total',
          'median' => 20,
          'sample' => [20] * 20
        }
      ]
    }
    best, is_h0_rejected = Benchmark.aggregate_and_rank([stat_one, stat_two])
    assert is_h0_rejected
    best['label'].must_equal 'first'
  end

  it 'ranks given stats' do
    stats = {
      'first' => [
        {
          'name' => 'total',
          'median' => 10,
          'sample' => [10] * 20
        }
      ],
      'second' => [
        {
          'name' => 'total',
          'median' => 20,
          'sample' => [20] * 20
        }
      ]
    }
    best, is_h0_rejected = Benchmark.rank(stats)
    assert is_h0_rejected
    best['label'].must_equal 'first'
  end
end