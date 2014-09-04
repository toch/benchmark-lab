
module Benchmark
  module Experiment
    class DescriptiveStatistics
      def initialize(sample)
        # raise exception if empty sample
        @sample = sample.sort
        @minimum, @maximum = @sample.minmax
        @median = calculate_median_of(@sample)
        @first_quartile = calculate_first_quartile_of(@sample)
        @third_quartile = calculate_third_quartile_of(@sample)
      end

      def sample
        @sample
      end

      def sample_size
        @sample.size
      end

      def minimum
        @minimum
      end

      def first_quartile
        @first_quartile
      end

      def median
        @median
      end

      def third_quartile
        @third_quartile
      end

      def maximum
        @maximum
      end

      def interquartile_range
        @third_quartile - @first_quartile
      end

      private

      # https://en.wikipedia.org/wiki/Median
      def calculate_median_of(data)
        return data[data.size / 2] if data.size.odd?

        (data[(data.size - 1) / 2] + data[data.size / 2]) / 2.0
      end

      # http://mathworld.wolfram.com/Quartile.html
      # https://en.wikipedia.org/wiki/Quartile
      def calculate_first_quartile_of(data)
        return calculate_median_of(data[0..(data.size / 2)]) if data.size.odd?

        calculate_median_of(data[0..((data.size - 1)/ 2)])
      end
      def calculate_third_quartile_of(data)
        return calculate_median_of(data[(data.size / 2)..-1]) if data.size.odd?

        calculate_median_of(data[(data.size/ 2)..-1])
      end

    end
  end
end