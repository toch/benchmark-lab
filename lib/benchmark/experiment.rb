require 'benchmark'
require 'benchmark/experiment/descriptive_statistics'
require 'benchmark/experiment/version'

module Benchmark
  module Experiment
    def experiment(sample_size, &blk)
    end
  end

  extend Benchmark::Experiment
end