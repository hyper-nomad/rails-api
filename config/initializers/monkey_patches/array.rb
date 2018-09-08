class Array
  # input: [2,1,2,1,2,3]
  # output:
  # {
  #   1 => 2,
  #   2 => 3,
  #   3 => 1
  # }
  def summarize
    self.sort.group_by{|i| i}.map{|k,v| [k, v.count] }.to_h
  end
end
