module ApplicationHelper
   def rrdump ob, inner=false
    out = inner ? "" : "
    <style>
    table.dump td {font-family:courier; padding:2px; }
    td.hash {background:#CDC4D3;}
    th.hash {background:#AA98AA;}
    td.array {background:#C9DDF1;}
    th.array {background:#98BEE5;}
    td.query {background:#D3D4C3;}
    th.query {background:#B4B697;}
    </style>
    "
    if ob.is_a? Hash
      out += "<table border='1' class='dump hash'><tr><th colspan='2' class='hash'>hash</th></tr>"
      ob.each_pair do |key, value|
        out += "<tr><td class='hash'>#{key}</td><td class='hash'>#{rrdump(value, true)}</td></tr>"
      end
      out += "</table>" 
    elsif ob.is_a? Array
      out += "<table border='1' class='dump array'><tr><th colspan='2' class='array'>array</th></tr>"
      ob.each_with_index do |item, i|
        out += "<tr><td class='array'>#{i}</td><td class='array'>#{rrdump(item, true)}</td></tr>"
      end
      out += "</table>"  
    elsif !(ob.is_a?( String)) && ob.respond_to?( :each)  
      out += "<table border='1' class='dump query'><tr><th colspan='2' class='query'>query</th></tr>"
      i=0
      ob.each do |item|
        out += "<tr><td class='query'>#{i}</td><td class='query'>#{rrdump(item, true)}</td></tr>"
        i += 1
      end
      out += "</table>"
    elsif ob.respond_to?(:attributes) && ob.attributes.respond_to?( :each)
      out += "<table border='1' class='dump hash'><tr><th colspan='2' class='hash'>object</th></tr>"
      ob.attributes.each do |q|
        out += "<tr><td class='hash'>#{q[0]}</td><td class='hash'>#{rrdump(q[1], true)}</td></tr>"
      end
      out += "</table>"  
    else
      out += ob.to_s     
    end
    return raw(out)
  end
  
  
end
