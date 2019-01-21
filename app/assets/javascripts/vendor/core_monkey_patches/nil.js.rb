class NilClass

  def try(*args)
    nil      
  end  
     
  def try!(*args)   
   nil   
  end

  def blank?
    true
  end

  def rb
    p 'warning rb called for nil'
  end
end