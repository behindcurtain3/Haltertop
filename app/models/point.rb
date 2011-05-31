class Point
	attr_accessor :row, :col

	def initialize(row, col)
		@row = row
		@col = col
	end

	def ==(p)
		return (@row.to_i == p.row.to_i && @col.to_i == p.col.to_i)
	end

	FILE_MAP = { 0 => 'a', 1 => 'b', 2 => 'c', 3 => 'd', 4 => 'e', 5 => 'f', 6 => 'g', 7 => 'h' }
  RANK_MAP = { 0 => 8, 1 => 7, 2 => 6, 3 => 5, 4 => 4, 5 => 3, 6 => 2, 7 => 1 }

	# takes string in notation form "a4" and converts to points
	def set(str)
		str.each_char do | c |
			if c.is_number?
				RANK_MAP.each_pair do |k,v|
					if v == c.to_i
						@row = k
					end
				end
			else
				FILE_MAP.each_pair do |k,v|
					if v == c
						@col = k
					end
				end
			end
		end
	end

	def notation
		file.to_s + rank.to_s
	end

	def file(c = @col)
    FILE_MAP.each_pair do |k,v|
			if k == c
        return v
			end
		end
  end

  def rank(r = @row)
    RANK_MAP.each_pair do |k,v|
			if k == r
        return v.to_s
			end
		end
  end
end