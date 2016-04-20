require_relative '../spec_helper'

describe Benchmark::Experiment::DescriptiveStatistics do
  let(:sample) {
    [49, 7, 6, 15, 43, 39, 47, 41, 42, 36, 40]
  }

  let(:data_name) { 'Test' }

  subject {
    Benchmark::Experiment::DescriptiveStatistics.new(sample, data_name)
  }

  it 'returns the name of the data collected' do
    subject.name.must_equal data_name
  end

  it 'returns the sample size' do
    subject.sample_size.must_equal 11
  end

  it 'returns the minimum of the sample' do
    subject.minimum.must_equal 6
  end

  it 'returns the maximum of the sample' do
    subject.maximum.must_equal 49
  end

  it 'returns the first quartile of the sample' do
    subject.first_quartile.must_equal 25.5
  end

  it 'returns the median of the sample' do
    subject.median.must_equal 40
  end

  it 'returns the third quartile of the sample' do
    subject.third_quartile.must_equal 42.5
  end

  it 'returns the interquartile range of the sample' do
    subject.interquartile_range.must_equal 17
  end
end
