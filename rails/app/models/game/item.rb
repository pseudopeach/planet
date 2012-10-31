class Game::Item < ActiveRecord::Base
  
  belongs_to :player
  belongs_to :item_type
  
  
  
  
  attr_accessor :xdata
  before_save :serialize_data
  after_initialize :deserialize_data 
  protected
  def serialize_data
    self.data = @xdata.to_json
  end
  def deserialize_data
    @xdata = self.data ? JSON(self.data) : {}
  end
end
