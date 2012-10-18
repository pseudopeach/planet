class OtherController < ApplicationController
  respond_to :html, :amf, :json
  
  def getComplex
    @obj = {:str=>"Hello", :arr=>["dsfs",3,5,6], :hsh=>{:a=>3,:b=>4} }
    render :amf => @obj
  end
  
end
