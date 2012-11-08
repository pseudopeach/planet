class SimpleAIPlayer < Game::Player
  
incase_of :my_turn?, :prefer=>Game::Action  
  
def my_turn? state
  state.status == Game::TURN_END
end

def should_respond? state
  state.status == Game::ACTION_STACKED
end

def should_respond_resolved? state
  state.status == Game::ACTION_RESOLVED
end
  
  
@@ai_tactics = []
def self.incase_of sit_test, options={}
  @@ai_tactics << { :sit_test=>sit_test.to_sym, :options=>options }
end

def execute_strategy(state)
  @@ai_tactics.each do |q|
    if self.send(q[:sit_test])
      act = q[:options[:prefer]]
      
      if act.respond_to? :legal? && act.legal?
        return act
      elsif act.is_a? Symbol && (act_o=self.send(act)).legal?
        return act_o
      end
    end
  end
  return nil
end
  

  
end