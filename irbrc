#!/usr/bin/ruby
require 'irb/completion'
require 'irb/ext/save-history'
require 'pp'

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"

IRB.conf[:PROMPT_MODE] = :SIMPLE

%w[rubygems looksee/shortcuts wirble].each do |gem|
  begin
    require gem
  rescue LoadError
  end
end

if defined? Wirble
  Wirble.init
  Wirble.colorize
end

class Object
  # list methods which aren't in superclass
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
  
  # print documentation
  #
  #   ri 'Array#pop'
  #   Array.ri
  #   Array.ri :pop
  #   arr.ri :pop
  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = self.kind_of?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    puts `ri '#{method}'`
  end
end

def copy(str)
  IO.popen('pbcopy', 'w') { |f| f << str.to_s }
end

def copy_history
  history = Readline::HISTORY.entries
  index = history.rindex("exit") || -1
  content = history[(index+1)..-2].join("\n")
  puts content
  copy content
end

def paste
  `pbpaste`
end

def ls  
  %x{ls}.split("\n")  
end  
  
def cd(dir)  
  Dir.chdir(dir)  
  Dir.pwd  
end  
  
def pwd  
  Dir.pwd  
end

def rl(file_name = nil)  
  if file_name.nil?  
    if !@recent.nil?  
      rl(@recent)   
    else  
      puts "No recent file to reload"  
    end  
  else  
    file_name += '.rb' unless file_name =~ /\.rb/  
    @recent = file_name   
    load "#{file_name}"  
  end  
end

load File.dirname(__FILE__) + '/.railsrc' if $0 == 'irb' && ENV['RAILS_ENV']
