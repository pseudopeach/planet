namespace :import do
  desc "Imports a CSV file into an ActiveRecord table"
  task :csv, :filename, :model, :needs => :environment do |task,args|
    added = 0
    updated = 0
    failed = []
    klass = Module.const_get(args[:model])
    lines = File.new(args[:filename]).readlines
    header = lines.shift.strip
    keys = header.split(',')
    lines.each do |line|
      values = line.strip.split(',')
      attributes = Hash[keys.zip values]
      begin
        if attributes.key?("id") && (found = klass.find_by_id(attributes["id"]))
          updated += 1
          attributes.each {|k,v| found[k] = v}
          found.save
        else
          added += 1
          ob = klass.new
          attributes.each {|k,v| ob[k] = v}
          ob.save
        end
      rescue
        failed << attributes[:id]
      end
    end
    puts "added:#{added} updated:#{updated} failed:#{failed.size}"
    puts failed.join "," if failed.size > 0
  end
  
  desc "Imports a CSV file into base_creatures table"
  task :csv2creature, [:filename] => :environment do |task,args|
    
    added = 0
    updated = 0
    klass = Terra::BaseCreature
    lines = File.new(args[:filename]).readlines
    header = lines.shift.strip
    keys = header.split(',')
    lines.each do |line|
      Terra::BaseCreature.transaction do
        values = line.strip.split(',')
        attributes = Hash[keys.zip values]
        xattrs = {}
        ob = nil
        if attributes.key?("id") && (ob = klass.find_by_id(attributes["id"]))
          updated += 1
          attributes.each do |k,v| 
            if ob.respond_to? k 
              ob[k] = v
            else
              xattrs["pa_"+k] = v
            end
          end
          ob.save
        else
          added += 1
          ob = klass.new
          attributes.each do |k,v| 
            if ob.respond_to? k 
              ob[k] = v
            else
              xattrs["pa_"+k] = v
            end
          end
          ob.save
        end #old/new swtich
        
        xattrs.each do |k,v|
          if arec = ob.creature_attributes.where(:name=>k).first
            arec.value = v
            arec.save
          else
            ob.creature_attributes << Terra::CreatureAttribute.new(:name=>k,:value=>v,:of_base_creature=>true)
          end
        end
      end #trans
    end #creature loop
    puts "added:#{added} updated:#{updated}"
  end
  
  
  
end