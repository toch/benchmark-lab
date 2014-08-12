require 'benchmark'
require 'benchmark/experiment/descriptive_statistics'
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

      stats = []

      times_to_measure = [
        :utime,
        :stime,
        :total,
        :real
      ]

      print "".ljust(width)
      print "\tuser     system      total        real\n"

      job.list.each do |label, item, sample|
        stats << {}
        print label.ljust(width)
        times_to_measure.each do |t|
          stats.last[t] = DescriptiveStatistics.new(sample.map(&t)).tap do |result|
            print "\t[#{'%.2f' % result.first_quartile},#{'%.2f' % result.median},#{'%.2f' % result.third_quartile}]"
          end
        end
        print "\n"
      end

      stats
    end
  end

  extend Benchmark::Experiment
end