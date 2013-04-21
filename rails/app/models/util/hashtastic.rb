module Util::Hashtastic
  
   module ClassMethods
      @@hash_excluded_keys ||= [] #move this up here
      def hash_exclude key, options = { }
          @@hash_excluded_keys << key.to_s
      end

      #added this (rename as required)
      def hash_excluded_keys
        @@hash_excluded_keys
      end
    end

    def self.included receiver
        receiver.extend ClassMethods
    end
  
  def to_hash
    out = {}

    keys = self.attribute_names - self.class.hash_excluded_keys
    keys.each do |n|
      out[n.to_s.camelize(:lower)] = self[n]
    end
    return out
  end
   
end