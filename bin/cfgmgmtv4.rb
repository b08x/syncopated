#!/usr/bin/env ruby
# frozen_string_literal: true

require 'tty-prompt'
require 'tty-box'
require 'tty-screen'
require 'tty-pager'
require 'tty-spinner'
require 'pastel'
require 'yaml'
require 'json'
require 'open3'
require 'fileutils'

# Configuration Class
class Configuration
  attr_reader :ansible_home, :playbooks_dir, :group_vars, :host_vars, :roles_home
  attr_accessor :inventory, :execute_mode

  def initialize
    @ansible_home = ENV['ANSIBLE_HOME'] || File.expand_path('~/.config/dotfiles')
    @inventory = File.join(@ansible_home, 'inventory.ini')
    @playbooks_dir = File.join(@ansible_home, 'playbooks')
    @group_vars = File.join(@ansible_home, 'group_vars')
    @host_vars = File.join(@ansible_home, 'host_vars')
    @roles_home = File.join(@ansible_home, 'roles')
    @execute_mode = ENV['EXECUTE_MODE'] == 'true'
  end

  def playbooks
    @playbooks ||= Dir.glob(File.join(@playbooks_dir, '*.yml'))
  end

  def groups
    @groups ||= Dir.children(group_vars).map { |group| group.gsub('.yml', '') }
  rescue Errno::ENOENT
    []
  end

  def hosts
    @hosts ||= Dir.children(host_vars).map { |host| host.gsub('.yml', '') }
  rescue Errno::ENOENT
    []
  end

  def roles
    @roles ||= Dir.children(roles_home)
  rescue Errno::ENOENT
    []
  end
end

# UI Class for styled output
class UIManager
  attr_reader :prompt, :pastel

  def initialize
    @prompt = TTY::Prompt.new
    @width = TTY::Screen.width
    @height = TTY::Screen.height
    @spinner = TTY::Spinner.new('[:spinner] :title', format: :pulse)
    @pastel = Pastel.new
  end

  def welcome_message
    box = TTY::Box.frame(
      width: @width - 4,
      height: 5,
      align: :center,
      padding: [1, 2],
      title: { top_left: '╭─┄', top_right: '┄─╮' },
      style: {
        fg: :bright_yellow,
        bg: :black,
        border: { fg: :bright_blue }
      }
    ) do
      'Syncopated Linux Ansible Manager v0.7.5'
    end
    puts box
  end

  def message(text, style = :info)
    colors = {
      info: :bright_blue,
      success: :bright_green,
      warning: :bright_yellow,
      error: :bright_red
    }

    box = TTY::Box.frame(
      width: @width - 4,
      padding: [1, 2],
      style: {
        fg: colors[style],
        border: { fg: colors[style] }
      }
    ) do
      text
    end
    puts box
  end

  def preview_command(command_parts, selections)
    box = TTY::Box.frame(
      width: @width - 4,
      padding: 1,
      title: { top_left: ' Preview ', top_right: ' Command ' },
      style: { border: { fg: :bright_cyan } }
    ) do
      [
        'Selected options:',
        "Playbook: #{selections[:playbook]}",
        "Hosts: #{selections[:hosts]&.join(', ')}",
        "Tags: #{selections[:tags]&.join(', ')}",
        "Task: #{selections[:task]}",
        '',
        'Command to execute:',
        command_parts.join(' ')
      ].join("\n")
    end
    puts box
  end

  def spinner_start(title)
    @spinner.update(title: title)
    @spinner.auto_spin
  end

  def spinner_stop
    @spinner.stop
  end
end

# Ansible Manager Class
class AnsibleManager
  def initialize
    @config = Configuration.new
    @ui = UIManager.new
    @selections = {}
    setup_logging
  end

  def setup_logging
    @log_dir = File.join(Dir.home, '.local', 'log', 'ansible')
    FileUtils.mkdir_p(@log_dir)
    @current_log = File.join(@log_dir, "ansible_#{Time.now.strftime('%Y%m%d_%H%M%S')}.log")
  end

  def extract_tasks(file)
    tasks = []
    File.readlines(file).each_with_index do |line, index|
      tasks << { file: file, line: index + 1, name: line.split('name:').last.strip } if line.match?(/^-\s+name:/)
    end
    tasks
  rescue Errno::ENOENT
    []
  end

  def select_playbook
    playbooks = @config.playbooks.map { |p| [File.basename(p), p] }.to_h
    return @ui.message("No playbooks found in #{@config.playbooks_dir}", :warning) if playbooks.empty?

    @ui.prompt.select('Select Playbook:', playbooks, per_page: 10)
  end

  def select_hosts
    inventory_content = File.read(@config.inventory)
    hosts = inventory_content.lines
                             .select { |line| line.match?(/^[^\s#]/) }
                             .map(&:strip)
                             .reject { |line| line.match?(/:\w+|=/) }

    return @ui.message('No hosts found in inventory', :warning) if hosts.empty?

    @ui.prompt.multi_select('Select Host(s):', hosts, per_page: 10)
  rescue Errno::ENOENT
    @ui.message("Inventory file not found: #{@config.inventory}", :error)
    []
  end

  def select_tags(playbook)
    return [] unless playbook && File.exist?(playbook)

    cmd = "ansible-playbook -i #{@config.inventory} #{playbook} --list-tags"
    output, status = Open3.capture2(cmd)

    if status.success?
      tags = output.scan(/TASK TAGS: \[(.*?)\]/)
                   .flatten
                   .first
                   &.split(',')
                   &.map(&:strip)
                   &.reject(&:empty?) || []

      return @ui.message('No tags found in playbook', :warning) if tags.empty?

      @ui.prompt.multi_select('Select Tags:', tags, per_page: 10)
    else
      @ui.message('Failed to get tags from playbook', :error)
      []
    end
  end

  def select_task
    return unless @selections[:playbook]

    tasks = Dir.glob(File.join(@config.roles_home, '**/tasks/*.yml')).flat_map do |file|
      extract_tasks(file)
    end

    return @ui.message('No tasks found', :warning) if tasks.empty?

    @ui.prompt.select('Select Task:', tasks.map { |t| t[:name] }, per_page: 10)
  end

  def build_command
    cmd_parts = ['ansible-playbook', '-i', @config.inventory]
    cmd_parts << (@config.execute_mode ? '' : '-C')
    cmd_parts << @selections[:playbook]
    cmd_parts << "--limit #{@selections[:hosts].join(',')}" if @selections[:hosts]&.any?
    cmd_parts << "--tags '#{@selections[:tags].join(',')}'" if @selections[:tags]&.any?
    cmd_parts << "--start-at-task '#{@selections[:task]}'" if @selections[:task]
    cmd_parts << "-e 'gather_facts=true'"
    cmd_parts.compact
  end

  def execute_playbook
    return @ui.message('Please select a playbook first.', :warning) if @selections[:playbook].nil?

    cmd_parts = build_command
    @ui.preview_command(cmd_parts, @selections)

    return unless @ui.prompt.yes?('Do you want to execute this playbook?')

    @ui.spinner_start('Executing playbook...')

    File.open(@current_log, 'w') do |log|
      Open3.popen3(cmd_parts.join(' ')) do |_stdin, stdout, stderr, wait_thr|
        while (line = stdout.gets)
          next if line.nil?

          log.puts(line)

          if line.match?(/TASK/)
            puts @pastel.blue(line)
          elsif line.match?(/ok:|changed:/)
            puts @pastel.green(line)
          elsif line.match?(/PLAY RECAP|ok=/)
            puts @pastel.yellow(line)
          else
            puts line
          end
        end

        if wait_thr.value.success?
          @ui.message('Playbook executed successfully!', :success)
        else
          error = stderr.read
          log.puts("\nERROR:\n#{error}")
          @ui.message("Execution failed: #{error}", :error)
        end
      end
    end

    @ui.spinner_stop

    return unless @ui.prompt.yes?('Would you like to view the detailed log?')

    pager = TTY::Pager.new
    pager.page(File.read(@current_log))
  end

  def reset_selections
    @selections.clear
    @ui.message('All selections have been reset.', :info)
  end

  def run
    @ui.welcome_message
    @ui.message('A set of roles for audio, desktop, development, and system configuration')

    loop do
      choices = {
        'Select Playbook' => 1,
        'Select Host(s)' => 2,
        'Select Tags' => 3,
        'Select Task' => 4,
        'Preview Command' => 5,
        'Execute Playbook' => 6,
        'Reset Selections' => 7,
        'Exit' => 8
      }

      action = @ui.prompt.select('Choose an action:', choices)

      case action
      when 1
        @selections[:playbook] = select_playbook
      when 2
        @selections[:hosts] = select_hosts
      when 3
        @selections[:tags] = select_tags(@selections[:playbook])
      when 4
        @selections[:task] = select_task
      when 5
        cmd_parts = build_command
        @ui.preview_command(cmd_parts, @selections)
      when 6
        execute_playbook
      when 7
        reset_selections
      when 8
        @ui.message('Goodbye!', :success)
        exit 0
      end
    end
  end
end

# Handle command line arguments
if ARGV.include?('-h') || ARGV.include?('--help')
  puts "Usage: #{$PROGRAM_NAME} [-h|--help] [-v|--version] [-x|--execute]"
  puts 'Options:'
  puts '  -h, --help     Show this help message'
  puts '  -v, --version  Show version'
  puts '  -x, --execute  Execute in live mode (no check mode)'
  exit 0
elsif ARGV.include?('-v') || ARGV.include?('--version')
  puts 'Ansible Menu v1.0.0'
  exit 0
elsif ARGV.include?('-x') || ARGV.include?('--execute')
  ENV['EXECUTE_MODE'] = 'true'
end

# Start the application
begin
  AnsibleManager.new.run
rescue Interrupt
  puts "\nGoodbye!"
  exit 0
rescue StandardError => e
  puts "\nError: #{e.message}"
  puts e.backtrace if ENV['DEBUG']
  exit 1
end
