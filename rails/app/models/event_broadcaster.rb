module EventBroadcaster
  def self.broadcastable msg
    @@broadcastable_msgs.push msg
  end
  
  def self.all_broadcastable_msgs
    return @@broadcastable_msgs
  end
  
  def add_observer observer, message, handler
    raise "Observer registered for invalid event message." unless @@broadcastable_msgs.find message
    @registry = {} unless @registry
    @registry[message] = [] unless @registry[message]
    @registry[message].push({:observer=>observer, :handler=>handler.to_sym})
  end
  
  def remove_observer observer, message
    if obs = @registry[message]
      obs.delete_if {|q| q[:observer]==observer && q[:message]==message}
    end
  end
  
  def broadcast_event message, obj
    raise "Message not registered as broadcastable" unless @@broadcastable_msgs.find message
    if obs = @registry[message]
      obj[:message] = message
      obs.each do |orec|
        orec[:observer].send(orec[:handler],obj)
      end
    end
  end
end