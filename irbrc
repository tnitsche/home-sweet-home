require 'irb/completion'
require 'pp'
require 'rubygems'
require 'tempfile'

class InteractiveEditor
  attr_accessor :editor
  def initialize(editor = :vim)
    @editor = editor.to_s
    if @editor == "mate"
      @editor = "mate -w"
    end
  end
  def edit
    unless @file
      @file = Tempfile.new("irb_tempfile")
    end
    system("#{@editor} #{@file.path}")
    execute
  end
  def execute
    @file.rewind
    Object.class_eval(@file.read)
    rescue Exception => error
      puts error
  end
end

def edit(editor)
  unless IRB.conf[:interactive_editors] && IRB.conf[:interactive_editors][editor]
    IRB.conf[:interactive_editors] ||= {}
    IRB.conf[:interactive_editors][editor] = InteractiveEditor.new(editor)
  end
  IRB.conf[:interactive_editors][editor].edit
end

def vi
  edit(:vim)
end

HISTFILE = "~/.irb.hist" unless Object.const_defined? "HISTFILE"
MAXHISTSIZE = 500 unless Object.const_defined? "MAXHISTSIZE"

IRB.conf[:AUTO_INDENT] = true
IRB.conf[:PROMPT_MODE] = :SIMPLE

ARGV.concat [ "--readline", "--prompt-mode", "simple" ]

begin
  if defined? Readline::HISTORY
    histfile = File::expand_path( HISTFILE )
    if File::exists?( histfile )
      lines = IO::readlines( histfile ).collect {|line| line.chomp}
      puts "Read %d saved history commands from %s." %
        [ lines.nitems, histfile ] if $DEBUG || $VERBOSE
      Readline::HISTORY.push( *lines )
    else
      puts "History file '%s' was empty or non-existant." %
        histfile if $DEBUG || $VERBOSE
    end

    Kernel::at_exit {
      lines = Readline::HISTORY.to_a.reverse.uniq.reverse
      lines = lines[ -MAXHISTSIZE, MAXHISTSIZE ] if lines.count{|x| !x.nil?} > MAXHISTSIZE
      $stderr.puts "Saving %d history lines to %s." %

        [ lines.length, histfile ] if $VERBOSE || $DEBUG
      File::open( histfile, File::WRONLY|File::CREAT|File::TRUNC ) {|ofh|
        lines.each {|line| ofh.puts line }
      }
    }
  end
end


# IRB verbosity: http://groups.google.com/group/ruby-talk-google/browse_thread/thread/9c1febbe05513dc0
module IRB 
  def self.result_format 
     conf[:PROMPT][conf[:PROMPT_MODE]][:RETURN] 
  end 
  def self.result_format=(str) 
     result_format.replace(str) 
  end 
  def self.show_results 
     self.result_format = "=> %s\n"
  end 
  def self.hide_results 
     self.result_format = '' 
  end 
end

class Object
  def verbose
    IRB.show_results
  end
  alias :v :verbose

  def silent
    IRB.hide_results
  end
  alias :s :silent

  alias :q :exit
end

class Object
  def history(how_many = MAXHISTSIZE)
    history_size = Readline::HISTORY.size
    # no lines, get out of here
    puts "No history" and return if history_size == 0
    start_index = 0
    # not enough lines, only show what we have
    if history_size <= how_many
      how_many  = history_size - 1
      end_index = how_many
    else
      end_index = history_size - 1 # -1 to adjust for array offset
      start_index = end_index - how_many 
    end
    start_index.upto(end_index) {|i| print_line i}
  end
  alias :h  :history

  # -2 because -1 is ourself
  def history_do(lines = (Readline::HISTORY.size - 2))
    irb_eval lines
  end 
  alias :h! :history_do

  def history_write(filename, lines)
    file = File.open(filename, 'w')
    get_lines(lines).each do |l|
      file << "#{l}\n"
    end
    file.close
  end
  
  # hack to handle JRuby bug
  def handling_jruby_bug(&block)
    if RUBY_PLATFORM =~ /java/
      puts "JRuby IRB has a bug which prevents successful IRB vi interoperation."
      puts "The JRuby team is aware of this and working on it."
      puts "(http://jira.codehaus.org/browse/JRUBY-2049)"
    else
      yield
    end
  end

  # TODO: history_write should go to a file, or the clipboard, or a file which opens in an application
  def history_to_vi
    handling_jruby_bug do
      file = Tempfile.new("irb_tempfile")
      get_lines(0..(Readline::HISTORY.size - 1)).each do |line|
        file << "#{line}\n"
      end
      file.close
      system("vim #{file.path}")
    end
  end
  alias :hvi :history_to_vi

  private
  def get_line(line_number)
    Readline::HISTORY[line_number] rescue ""
  end

  def get_lines(lines = [])
    return [get_line(lines)] if lines.is_a? Fixnum
    out = []
    lines = lines.to_a if lines.is_a? Range
    lines.each do |l|
      out << Readline::HISTORY[l]
    end
    out
  end

  def print_line(line_number, show_line_numbers = true)
    print line_number.to_s + ": " if show_line_numbers
    puts get_line(line_number)
  end

  def irb_eval(lines)
    to_eval = get_lines(lines)
    to_eval.each {|l| Readline::HISTORY << l}
    eval to_eval.join("\n")
  end
end

script_console_running = ENV.include?('RAILS_ENV') && IRB.conf[:LOAD_MODULES] && IRB.conf[:LOAD_MODULES].include?('console_with_helpers')
rails_running = ENV.include?('RAILS_ENV') && !(IRB.conf[:LOAD_MODULES] && IRB.conf[:LOAD_MODULES].include?('console_with_helpers'))
irb_standalone_running = !script_console_running && !rails_running

if script_console_running
# should make a switch
# require 'logger'
# Object.const_set(:RAILS_DEFAULT_LOGGER, Logger.new(STDOUT))
end

# ri stuff
module Kernel
  def r(arg)
    puts `qri "#{arg}"`
  end
  private :r
end

class Object
  def puts_ri_documentation_for(obj, meth)
    case self
    when Module
      candidates = ancestors.map{|klass| "#{klass}::#{meth}"}
      candidates.concat(class << self; ancestors end.map{|k| "#{k}##{meth}"})
    else
      candidates = self.class.ancestors.map{|klass|  "#{klass}##{meth}"}
    end
    candidates.each do |candidate|
      #puts "TRYING #{candidate}"
      desc = `qri '#{candidate}'`
      unless desc.chomp == "nil"
      # uncomment to use ri (and some patience)
      #desc = `ri -T '#{candidate}' 2>/dev/null`
      #unless desc.empty?
        puts desc
        return true
      end
    end
    false
  end
  private :puts_ri_documentation_for

  def method_missing(meth, *args, &block)
    if md = /ri_(.*)/.match(meth.to_s)
      unless puts_ri_documentation_for(self,md[1])
        "Ri doesn't know about ##{meth}"
      end
    else
      super
    end
  end

  def ri_(meth)
    unless puts_ri_documentation_for(self,meth.to_s)
      "Ri doesn't know about ##{meth}"
    end
  end
end

unless Object.const_defined? "RICompletionProc"
  RICompletionProc = proc{|input|
    bind = IRB.conf[:MAIN_CONTEXT].workspace.binding
    case input
    when /(\s*(.*)\.ri_)(.*)/
      pre = $1
      receiver = $2
      meth = $3 ? /\A#{Regexp.quote($3)}/ : /./ #}
      begin
        candidates = eval("#{receiver}.methods", bind).map do |m|
          case m
          when /[A-Za-z_]/; m
          else # needs escaping
            %{"#{m}"}
          end
        end
        candidates = candidates.grep(meth)
        candidates.map{|s| pre + s }
      rescue Exception
        candidates = []
      end
    when /([A-Z]\w+)#(\w*)/ #}
      klass = $1
      meth = $2 ? /\A#{Regexp.quote($2)}/ : /./
      candidates = eval("#{klass}.instance_methods(false)", bind)
      candidates = candidates.grep(meth)
      candidates.map{|s| "'" + klass + '#' + s + "'"}
    else
      IRB::InputCompletor::CompletionProc.call(input)
    end
  }
end
#Readline.basic_word_break_characters= " \t\n\"\\'`><=;|&{("
Readline.basic_word_break_characters= " \t\n\\><=;|&"
Readline.completion_proc = RICompletionProc

