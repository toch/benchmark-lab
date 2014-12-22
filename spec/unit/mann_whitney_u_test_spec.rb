require_relative '../spec_helper'

describe Benchmark::Experiment::MannWhitneyUTest do
  let(:x)         { [19, 22, 16, 29, 24] }
  let(:y_no_ties) { [20, 11, 17, 12] }
  let(:y_ties)    { [19, 20, 11, 17, 12] }

  it 'calculates U' do
    Benchmark::Experiment::MannWhitneyUTest::calculate_U(x, y_no_ties).must_equal [3.0, 17.0]
  end

  it 'calculates U with ties' do
    Benchmark::Experiment::MannWhitneyUTest::calculate_U(x, y_ties).must_equal [4.5, 20.5]
  end

  it 'calculates the standardized value z' do
    Benchmark::Experiment::MannWhitneyUTest::calculate_z(x, y_no_ties).must_be_close_to -1.715
  end

  it 'calculates the standardized value z with ties' do
    Benchmark::Experiment::MannWhitneyUTest::calculate_z(x, y_ties).must_be_close_to -1.853
  end

  it 'calculates p-value' do
    z = Benchmark::Experiment::MannWhitneyUTest::calculate_z(x, y_no_ties)
    Benchmark::Experiment::MannWhitneyUTest::calculate_probability_z(z).must_be_close_to 0.086
  end

  it 'rejects null hypothesis' do
    refute Benchmark::Experiment::MannWhitneyUTest::is_null_hypothesis_rejected?(0.9, 0.05)
  end
end
