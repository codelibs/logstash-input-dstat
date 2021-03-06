# encoding: utf-8
require "logstash/inputs/base"
require "stud/interval"
require "socket" # for Socket.gethostname
require 'csv'

# Generate a repeating message.
#
# This plugin is intented only as an example.

class LogStash::Inputs::Dstat < LogStash::Inputs::Base
  config_name "dstat"

  default :codec, "plain"

  config :option, :validate => :string, :default => ""

  config :interval, :validate => :number, :default => 30

  config :tmpfile, :validate => :string, :default => "/tmp/logstash-dstat.csv"

  config :stat_hash, :validate => :hash, :default => {
    'load avg' => {'1m' => 'loadavg-short', '5m' => 'loadavg-middle', '15m' => 'loadavg-long'},
    'total cpu usage' => {'usr' => 'cpu-usr', 'sys' => 'cpu-sys', 'idl' => 'cpu-idl', 'wai' => 'cpu-wai', 'hiq' => 'cpu-hiq', 'siq' => 'cpu-siq'},
    'net/total' => {'recv' => 'net-recv', 'send' => 'net-send'},
    '/' => {'used' => 'disk-used', 'free' => 'disk-free'},
    'memory usage' => {'used' => 'mem-used', 'buff' => 'mem-buff', 'cach' => 'mem-cach', 'free' => 'mem-free'},
    'dsk/total' => {'read' => 'dsk-read', 'writ' => 'dsk-writ'},
    'paging' => {'in' => 'paging-in', 'out' => 'paging-out'},
    'system' => {'int' => 'sys-int', 'csw' => 'sys-csw'},
    'swap' => {'used' => 'swap-used', 'free' => 'swap-free'},
    'procs' => {'run' => 'procs-run', 'blk' => 'procs-blk', 'new' => 'procs-new'}
  }

  public
  def register
    @logger.info("Registering Dstat Input", :type => @type, :command => @option, :interval => @interval)
    @host = Socket.gethostname
    @command = 'dstat ' + option + ' --output ' + @tmpfile + ' 1 1'
  end # def register

  def run(queue)
    while !stop?
      clear_tmpfile(@tmpfile)
      lines = exec_dstat(@command, @tmpfile)
      events = create_dstat_events(lines)
      events.each{|event|
        decorate(event)
        queue << event
      }
      Stud.stoppable_sleep(@interval) { stop? }
    end
  end

  def stop
  end

  def exec_dstat(cmd, tmpfile)
    @logger.debug? && @logger.debug("Executing dstat", :command => cmd)
    begin
      `#{cmd}`
      File.open(tmpfile) do |file|
        file.read.split("\n")
      end
    rescue Exception => e
      @logger.error("Exception while running dstat",
        :command => option, :e => e, :backtrace => e.backtrace)
    ensure
      stop
    end
  end

  def clear_tmpfile(file)
    File.open(file,"w") do |file|
    end
  end

  def create_dstat_events(lines)
    events = []
    top_columns = []
    second_columns = []

    lines.each_with_index do |line, line_number|
      line.delete!("\"")
      next if line == ""
      case line_number
      when 0..4
      when 5
        top_columns = CSV.parse_line(line)
        top_columns.each_with_index do |value, i|
          if value.nil? || value == ""
            top_columns[i] = top_columns[i-1]
          end
        end
      when 6
        second_columns = CSV.parse_line(line)
      when 7
      when 8
        CSV.parse_line(line).each_with_index do |value, i|
          stat = resolve_stat(top_columns[i], second_columns[i])
          if !stat.nil?
            event = LogStash::Event.new("stat" => stat, "value" => value, "host" => @host)
            events << event
          end
        end
      end
    end

    events
  end

  def resolve_stat(top_column, second_column)
    @stat_hash[top_column] ? @stat_hash[top_column][second_column] : nil
  end
end # class LogStash::Inputs::Dstat
