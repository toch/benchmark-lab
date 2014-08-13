
module Benchmark
  module Experiment
    module MannWhitneyUTest
      def self.calculate_U(x, y)
        ranked = concatenate_and_label(x, y)
        
        rank!(ranked)

        adjust_ties!(ranked)

        r_x = rank_sum(ranked, :x)
        r_y = rank_sum(ranked, :y)

        n_x = x.size
        n_y = y.size

        u_x = calculate_u_sample(n_x, n_y, r_x)
        u_y = calculate_u_sample(n_y, n_x, r_y)

        [u_x, u_y].minmax.first
      end

      private

      def self.concatenate_and_label(x, y)
        ranked = []
        
        ranked += x.map { |e| [e, :x] }
        ranked += y.map { |e| [e, :y] }
      end

      def self.rank!(ranked)
        ranked.sort!

        ranked.inject(1) do |rank, elem|
          elem << rank
          rank + 1
        end
      end

      def self.rank_sum(ranked, label)
        ranked
          .select { |elem| elem[1] == label }
          .inject(0) {|rank_sum, elem| rank_sum + elem.last }
      end

      def self.adjust_ties!(ranked)
        ties = {}

        ranked
          .group_by { |e| e.first }
          .reject { |_,v| v.size < 2 }
          .each do |score, data|
            ties[score] = data.inject(0) do |sum, elem|
              sum + elem.last
            end / data.size.to_f
          end 

        ranked.map! do |elem|
          elem[-1] = ties[elem.first] if ties.keys.include? elem.first
          elem
        end if ties.keys.size > 0
      end

      def self.calculate_u_sample(n, n_other, r)
        n * n_other + n * (n + 1) / 2.0 - r
      end
    end
  end
end