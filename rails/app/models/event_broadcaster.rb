module EventBroadcaster
  def add_observer observer, message, handler
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
    if obs = @registry[message]
      obj[:message] = message
      obs.each do |orec|
        orec[:observer].send(orec[:handler],obj)
      end
    end
  end
end