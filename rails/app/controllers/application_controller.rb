class ApplicationController < ActionController::Base
  before_filter :unpack_amf_params 
  
  protected
  def unpack_amf_params
    if params[0]
      params[0].each_pair do |key,value|
        params[key.to_sym] = value
      end
    end
    return true
  end
  
end
