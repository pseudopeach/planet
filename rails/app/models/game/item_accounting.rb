module Game::ItemAccounting
  def item_count(item_type_id)
    return self.items.where(:item_type_id=>item_type_id).sum(:item_qty)
  end
  
  def item_count_add(item_type_id, delta)
    raise "Delta must be numeric." unless delta.is_a? Numeric
    Game::Item.transaction do
      if found = items.where(:item_type_id=>item_type_id).first
        Game::Item.update_all("item_qty = item_qty + #{delta}",:id=>found.id)
      else
        new_item = Game::Item.new(:item_type_id=>item_type_id, :item_qty=>delta)
        new_item.user = self.user if self.respond_to? :user
        self.items << new_item
      end
      if delta > 0
        Game::ItemType.update_all("created_count = created_count + #{delta}",:id=>item_type_id)
      else
        Game::ItemType.update_all("destroyed_count = destroyed_count + #{-delta}",:id=>item_type_id)
      end
    end
  end
  
  
end