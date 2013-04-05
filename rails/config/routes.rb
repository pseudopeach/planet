TestBed::Application.routes.draw do
  match ':controller(/:action(/:id(.:format)))'
  
  map_amf :controller => "OtherController"
  map_amf :controller => "PlayController"
end
