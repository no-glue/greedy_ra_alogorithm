require "greedy_ra_algorithm/version"

module GreedyRaAlgorithm
  class GreedyRaAlgorithm
    # gets distance between cities
    def euc_2d(c1, c2)
      Math.sqrt((c2[0] - c1[0]) ** 2.0 + (c2[1] - c1[1]) ** 2.0).round
    end

    # gets distance between two cities
    def cost(shake, cities)
      distance = 0
      shake.each_with_index do |c1, i|
        c2 = (i == (shake.size - 1)) ? shake[0] : shake[i + 1]
        # +++ get distance between two cities
        distance += euc_2d cities[c1], cities[c2]
      end
      distance
    end

    # gets reverse in range
    def two_opt(shake)
      perm = Array.new(shake)
      c1, c2 = rand(perm.size), rand(perm.size)
      collection = [c1]
      collection << ((c1 == 0 ? perm.size - 1 : c1 - 1))
      collection << ((c1 == perm.size - 1) ? 0 : c1 + 1)
      c2 = rand(perm.size) while collection.include? (c2)
      c1, c2 = c2, c1 if c2 < c1
      # +++ reverses in range
      perm[c1...c2] = perm[c1...c2].reverse
      perm
    end

    # does two opt
    def local_search(best, cities, max_no_improv)
      count = 0
      begin
        candidate = {:vector => two_opt(best[:vector])}
        candidate[:cost] = cost(candidate[:vector], cities)
        count = (candidate[:cost] < best[:cost]) ? 0 : count + 1
        best = candidate if candidate[:cost] < best[:cost]
      end until count >= max_no_improv
      best
    end

    #get solution
    def randomized_greedy_solution(cities, greedy)
      candidate = {}
      candidate[:vector] = [rand(cities.size)]
      allCities = Array.new(cities.size){|i| i}
      while candidate[:vector].size < cities.size
        candidates = allCities - candidate[:vector]
        costs = Array.new(candidates.size) do |i|
          euc_2d(cities[candidate[:vector].last], cities[i])
        end
        rcl, max, min = [], costs.max, costs.min
        costs.each_with_index do |cost, i|
          rcl << candidates[i] if cost <= (min + greedy * (max - min))
        end
        candidate[:vector] << rcl[rand(rcl.size)]
      end
      candidate[:cost] = cost(candidate[:vector], cities)
      candidate
    end

    # search
    def search(cities, max_iter, max_no_improv, greedy)
      best = nil
      max_iter.times do |iter|
        candidate = randomized_greedy_solution(cities, greedy)
        candidate = local_search(candidate, cities, max_no_improv)
        best = candidate if best.nil? or candidate[:cost] < best[:cost]
        puts " > iteration #{(iter + 1)}, best #{best[:cost]}"
      end
      best
    end
  end
end
