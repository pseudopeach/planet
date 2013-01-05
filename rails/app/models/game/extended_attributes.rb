module Game::ExtendedAttributes
  def self.included receiver
    receiver.extend ClassMethods
  end

  module ClassMethods
    def xdata_attr(name, options={})
      name_s = name.to_s
      class_name = options[:class_name] ? options[:class_name] : ("Terra::"+name_s.camelize)
      model_class = class_name.constantize
      col_name = :id # options[:column_name] ? options[:column_name] : "id"
      define_method name.to_sym do
        return @loaded_xdata[name] if @loaded_xdata[name]
        key = @xdata[name_s+"_id"]
        return nil unless key
        @loaded_xdata[name] = model_class.find_by_id(key)
        return @loaded_xdata[name]
      end
      define_method "#{name.to_s}=".to_sym do |input|
        @loaded_xdata[name] = input
        @xdata[(name_s+"_id").to_sym] = input.send col_name
      end
    end #xattr
  end #ClassMethods
  
  def serialize_data
    self.data = @xdata.empty? ? nil : @xdata.to_json
  end
  def deserialize_data
    @xdata = self.data ? JSON(self.data) : {}
    @loaded_xdata = {}
  end
  
end