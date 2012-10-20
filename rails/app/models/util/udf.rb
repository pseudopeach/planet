class Util::UDF
  
  def self.underscore input
    fn = input.gsub(/::/, '/')
    fn.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    fn.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    fn.tr!("-", "_")
    return fn.downcase
  end
  
  def self.as2rb path
    regs = []
    regs.push ["()", '']
    regs.push [/^public\s+class\s+(\w+)(\s+extends)(\s+\w+).*/, 'class \1 < \3']
    regs.push [/^public\s+class\s+(\w+).*/, 'class \1']
    regs.push [/function set (\w+)(.*)/, 'def \1=\2']
    regs.push [/function get (\w+)(.*)/, 'def \1\2']
    regs.push [/function is(\w+)(.*)/, 'def \1?\2']
    regs.push ["static function ", 'def self.']
    regs.push ["function ", 'def ']
    regs.push [/(public|protected|private) var .*/, '']
    regs.push [/for\(.*?;.*?<(\w+).length;.*?\)/, '\1.each do |q|']
    regs.push ["//", '#']
    regs.push ["}else if", 'elsif']
    regs.push ["}else", 'else']
    regs.push [/^import [\w\.]+;/, '']
    regs.push [/\{/, '']
    regs.push [/\}/, 'end']
    regs.push [/(\w+)\+\+/, '\1 += 1']
    regs.push [/(\w|\)|):\w+/, '\1']
    regs.push [/(\W)null(\W)/, '\1nil\1']
    regs.push ["var ", '']
    regs.push [/^public /, '']
    regs.push [/;/, '']
    
    file = File.open(path,"r")
    
    dirs = path.split(/\/|\\/)
    fn = dirs.pop
    fn = fn.split(".").first
    
    fn = UDF.underscore fn 
    fn += ".rb"
    outpath = dirs.join("/")
    outpath = outpath.blank? ? fn : (outpath +"/"+ fn)
    puts "writing to #{outpath}..."
    outfile = File.open(outpath,"w")
    
    
    file.each_line do |line|
      ws = line.sub(/^(\s*)(.*)\n/,'\1')
      line.lstrip!

      regs.each do |r|
        line.gsub!(r.first,r.last)
      end
      line = (line.split(/\s+/).map {|q| UDF.underscore q}).join(" ")
      line = ws + line
      outfile.puts line
    end
    file.close
    outfile.close
  end
  
  
end