require 'benchmark'
require 'benchmark/experiment/descriptive_statistics'
require 'benchmark/experiment/mann_whitney_u_test'
require 'benchmark/experiment/version'

module Benchmark
  class Sample
    include Enumerable

    def initialize
      @observations = []
    end

    def <<(observation)
      @observations << observation
    end

    def each(&block)
      @observations.each do |observation|
        if block_given?
          block.call observation
        else
          yield observation
        end
      end
    end
  end

  class Job
    alias old_item item
    def item(label = "", &blk)
      old_item(label, &blk)
      @list.last << Sample.new
      @list.last << []
      self
    end

    def benchmark(sample_size)
      @list.each do |label, item, sample, stats|
        sample_size.times.each do
          sample << Benchmark.measure(label, &item)
        end

        Experiment::MEASURED_TIMES.keys.each do |time_name|
          stats << Benchmark::Experiment::DescriptiveStatistics.new(sample.map(&time_name), time_name)
        end
      end
    end

    alias report item
  end

  module Experiment
    MEASURED_TIMES =
      {
        utime: 'user',
        stime: 'system',
        total: 'total',
        real: 'real'
      }

    def rank(all_stats, alpha = 0.05)
      ranked = all_stats.map do |stats|
        stats.select{ |stat| stat.name == :total }.first
      end.sort_by { |stat| stat.median }
      is_h0_rejected = true
      if (all_stats.size > 1)
        z = Benchmark::Experiment::MannWhitneyUTest::calculate_z(ranked.first.sample, ranked[1].sample)
        p_value = Benchmark::Experiment::MannWhitneyUTest::calculate_probability_z(z)
        is_h0_rejected = Benchmark::Experiment::MannWhitneyUTest::is_null_hypothesis_rejected?(p_value, alpha)
      end

      return ranked.first, is_h0_rejected
    end

    def experiment(sample_size, &blk)
      width = 0
      job = Job.new(width)
      yield(job)
      width = job.width + 1

      job.benchmark(sample_size)

      print "".ljust(width)
      print "\tuser     system      total        real\n"

      all_stats = []

      job.list.each do |label, _, _, stats|
        print label.ljust(width)

        all_stats << stats

        stats.each do |stat|
          print "\t[#{'%.2f' % stat.first_quartile},#{'%.2f' % stat.median},#{'%.2f' % stat.third_quartile}]"
        end
        print "\n"
      end

      best, is_the_best_significative = rank(all_stats)

      puts "The best #{best} is #{is_the_best_significative ? "" : "not"} significantly (95%) better (total time)."

      all_stats
    end
  end

  extend Benchmark::Experiment
end