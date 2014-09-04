require 'benchmark'
require 'benchmark/experiment/descriptive_statistics'
require 'benchmark/experiment/mann_whitney_u_test'
require 'benchmark/experiment/version'

module Benchmark
  class Job
    alias old_item item
    def item(label = "", &blk)
      old_item(label, &blk)
      @list.last << []
      self
    end

    alias report item
  end

  module Experiment
    def experiment(sample_size, &blk)
      width = 0
      job = Job.new(width)
      yield(job)
      width = job.width + 1

      sample_size.times.each do
        job.list.each do |label, item, sample|
          sample << Benchmark.measure(label, &item)
        end
      end

      stats = {}

      times_to_measure = [
        :utime,
        :stime,
        :total,
        :real
      ]

      print "".ljust(width)
      print "\tuser     system      total        real\n"

      job.list.each do |label, item, sample|
        stats[label] = {}
        print label.ljust(width)
        times_to_measure.each do |t|
          stats[label][t] = DescriptiveStatistics.new(sample.map(&t)).tap do |result|
            print "\t[#{'%.2f' % result.first_quartile},#{'%.2f' % result.median},#{'%.2f' % result.third_quartile}]"
          end
        end
        print "\n"
      end

      ranked = stats.sort_by { |_, elem| elem[:total].median }

      if (stats.size > 1)
        z = Benchmark::Experiment::MannWhitneyUTest::calculate_z(ranked.first.last[:total].sample, ranked[1].last[:total].sample)
        p_value = Benchmark::Experiment::MannWhitneyUTest::calculate_probability_z(z)

        puts "The best #{ranked.first.first} is #{Benchmark::Experiment::MannWhitneyUTest::is_null_hypothesis_rejected?(p_value, 0.05) ? "" : "not"} significantly (95%) better (total time)."
      end

      stats
    end
  end

  extend Benchmark::Experiment
end