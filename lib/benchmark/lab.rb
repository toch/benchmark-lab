require 'benchmark'
require 'benchmark/lab/descriptive_statistics'
require 'benchmark/lab/mann_whitney_u_test'
require 'benchmark/lab/version'

require 'json'

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
    def item(label = '', &blk)
      old_item(label, &blk)
      @list.last << Sample.new
      @list.last << []
      self
    end

    def observe_and_summarize(sample_size)
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

    def observe_and_summarize(sample_size, &blk)
      job = Job.new(0)
      yield(job)
      job.observe_and_summarize(sample_size)
      all_stats = job.list.map{ |label, _, _, stats| [label, stats] }.to_h
      all_stats.to_json
    end

    def aggregate_and_rank(jsons)
      return if jsons.empty?
      all_stats = jsons.inject({}) { |elem, hsh| hsh.merge(elem) }
      rank(all_stats)
    end

    def experiment(sample_size, &blk)
      all_stats = JSON.parse(observe_and_summarize(sample_size, &blk))
      print_stats(all_stats)

      best, is_the_best_significative = rank(all_stats)

      puts "The best \"#{best['label']}\" is #{is_the_best_significative ? '' : 'not '}significantly (95%) better (total time)."

      all_stats
    end

    def rank(all_stats, alpha = 0.05)
      ranked = all_stats.map do |label, stats|
        total = stats.select{ |stat| stat['name'] == 'total' }.first
        total['label'] = label
        total
      end.sort_by { |stat| stat['median'] }
      is_h0_rejected = true
      if all_stats.size > 1
        z = Benchmark::Experiment::MannWhitneyUTest::calculate_z(ranked.first['sample'], ranked[1]['sample'])
        p_value = Benchmark::Experiment::MannWhitneyUTest::calculate_probability_z(z)
        is_h0_rejected = Benchmark::Experiment::MannWhitneyUTest::is_null_hypothesis_rejected?(p_value, alpha)
      end

      return ranked.first, is_h0_rejected
    end

    def iterative_experiment
    end

    private

    def print_stats(all_stats)
      width = label_width(all_stats)

      lines = []
      spacing = [0] * MEASURED_TIMES.size
      tab = ' ' * 4

      all_stats.each do |label, stats|
        line = ''
        line << label.ljust(width)

        stats.each_with_index do |stat, index|
          value = "#{tab}[#{'%.2f' % stat['first_quartile']},#{'%.2f' % stat['median']},#{'%.2f' % stat['third_quartile']}]"
          spacing[index] = [spacing[index], value.length].minmax.last
          line << value
        end
        line << "\n"
        lines << line
      end

      print ''.ljust(width)
      MEASURED_TIMES.values.each_with_index do |head, index|
        print "#{tab}#{head}".ljust(spacing[index])
      end
      print "\n"

      lines.each { |line| print line }
    end

    def label_width(all_stats)
      label_widths = all_stats.map { |label, _| label.to_s.length }
      label_widths.minmax.last
    end

  end

  extend Benchmark::Experiment
end
