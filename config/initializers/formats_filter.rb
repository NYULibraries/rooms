# frozen_string_literal: true 

ActionDispatch::Request.prepend(Module.new do 
    def formats 
      super().select do |format| 
        format.symbol || format.ref == "*/*" 
      end 
    end 
  end) 