class ApplicationController < ActionController::Base
  before_filter :unpack_amf_params 
  
  protected
  def unpack_amf_params
    if params[0]
      params[0].each_pair do |key,value|
        params[key.underscore.to_sym] = value
      end
    end
    return true
  end
  
  def to_hash(input)
    out = {}
    input.attribute_names.each do |n|
      out[n.to_s.camelize(:lower)] = input[n]
    end
    return out
  end
  
end
