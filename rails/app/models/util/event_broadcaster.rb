module Util::EventBroadcaster
  def broadcastable msg
    @broadcastable_msgs = [] unless @broadcastable_msgs
    @broadcastable_msgs.push msg
  end
  
  def all_broadcastable_msgs
    return @broadcastable_msgs
  end
  
  def add_observer observer, message, handler
    raise "Observer registered for invalid event message: #{message}." unless @broadcastable_msgs.index message
    raise "Observer doesn't implement handler #{handler}." unless observer.respond_to? handler
    @observer_registry = {} unless @observer_registry
    @observer_registry[message] = [] unless @observer_registry[message]
    @observer_registry[message].push({:observer=>observer, :handler=>handler.to_sym})
    return true
  end
  
  def remove_observer observer, message
    if obs = @observer_registry[message]
      old_len = obs.length
      return obs.delete_if {|q| q[:observer]==observer}.length != old_len
    end
    return false
  end
  
  def broadcast_event message, obj
    raise "Message: #{message} is not registered as broadcastable" unless @broadcastable_msgs.index message
    @observer_registry = {} unless @observer_registry
    if obs = @observer_registry[message]
      obj[:message] = message
      obs.each do |orec|
        orec[:observer].send(orec[:handler],obj)
      end
    end
    return nil
  end
end