require_relative '../spec_helper'

describe Benchmark::Experiment::MannWhitneyUTest do
  let(:x) {
    [1.0, 1.5, 0.5, 1.75, 1.25]
  }

  let(:y) {
    [1.0, 2.0, 1.75, 2.5, 1.8]
  }

  it 'calculates U' do
    Benchmark::Experiment::MannWhitneyUTest::calculate_U(x, y).must_equal [21.0, 4.0]
  end
end

