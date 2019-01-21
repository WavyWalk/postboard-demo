class Subtitle < Model

  register

  attributes :from, :to, :style, :content, :is_rendered


  def self.map_bserach(array, from_time_start, min, max, result_array, direction, &block)

    if `#{min} > #{max}`
      return result_array
    end

    mid_index = `Math.floor((#{max} + #{min}) / 2)`

    value_at_mid_index = array[mid_index]

    if value_at_mid_index.from > from_time_start
      direction = false #right
      if yield(value_at_mid_index)
        result_array << value_at_mid_index
      end
      self.map_bserach(array, from_time_start, min, `#{mid_index} - 1`, result_array, direction, &block)
    elsif value_at_mid_index.from < from_time_start
      direction = true #left
      if yield(value_at_mid_index)
        result_array << value_at_mid_index
      end
      self.map_bserach(array, from_time_start, `#{mid_index} + 1`, max, result_array, direction, & block)
    elsif yield(value_at_mid_index) #worst case that first guess is eq to time will break algorithm, but thin it'll not happen at unacceptable rate
      result_array << value_at_mid_index
      if direction
        self.map_bserach(array, from_time_start, min, `#{mid_index} - 1`, result_array, direction, &block)
      else
        self.map_bserach(array, from_time_start, `#{mid_index} + 1`, max, result_array, direction, &block)
      end
    else
      return result_array
    end

  end

  def self.create_for_new
    self.new({from: 0, to: 0})
  end

  def to_json
    self.attributes.to_json
  end

end
