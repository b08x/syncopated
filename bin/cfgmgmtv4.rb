#!/usr/bin/env ruby
# frozen_string_literal: true

require 'cli/ui'
require 'yaml'
require 'json'
require 'csv'
require 'open3'
require 'tty-prompt'

# Configuration
class Configuration
  attr_reader :ansible_home, :inventory, :playbooks, :group_vars, :host_vars, :roles_home, :tags, :groups, :hosts,
              :roles
  attr_writer :tags, :groups, :hosts, :roles

  def initialize
    @ansible_home = ENV['ANSIBLE_HOME'] || File.expand_path('..', __dir__)
    @inventory = File.join(@ansible_home, 'inventory.ini')
    @playbooks = File.join(@ansible_home, 'playbooks')
    @group_vars = File.join(@ansible_home, 'group_vars')
    @host_vars = File.join(@ansible_home, 'host_vars')
    @roles_home = File.join(@ansible_home, 'roles')
    @tags = [] # Dynamically generated later
    @groups = [] # Dynamically generated later
    @hosts = [] # Dynamically generated later
    @roles = [] # Dynamically generated later
  end
end

# Ansible Project Class
class AnsibleProject
  attr_reader :playbooks, :group_vars, :host_vars, :tags

  def initialize(config)
    @config = config
    @playbooks = Dir.children(@config.playbooks).map { |file| File.join(@config.playbooks, file) }
    @group_vars = @config.group_vars
    @host_vars = @config.host_vars
  end

  def tags(playbook)
    `ansible-playbook -i #{@config.inventory} #{playbook} --list-tags | awk -F 'TASK TAGS:' '{print $2}'`.chomp.strip.gsub(
      /\[|\]|,/, ''
    )
  end

end

# UI Class
class UI
  def initialize(config)
    @config = config
    @prompt = TTY::Prompt.new
  end

  def select_playbook(ansible_project)
    @prompt.select('Select Playbook', ansible_project.playbooks)
  end

  def select_type
    @prompt.select('Select Type', ['n/a', 'tags', 'roles'])
  end

  def select_tags(playbook, ansible_project)
    # Get tags dynamically from the playbook
    tags = ansible_project.tags(playbook)
    @prompt.multi_select('Select Tags', tags.split(" "))
  end

  def select_roles
    @prompt.multi_select('Select Roles', @config.roles)
  end

  def select_limit
    @prompt.select('Select Limit', %w[all groups hosts localhost])
  end

  def select_group
    @prompt.multi_select('Select Group', @config.groups)
  end

  def select_host
    @prompt.multi_select('Select Host', @config.hosts)
  end

end

# Main Script
config = Configuration.new

# Dynamically generate lists from Ansible project
# config.tags = `ansible-playbook -i #{config.inventory} #{config.playbooks} --list-tags | awk -F 'TASK TAGS:' '{print $2}'`.chomp.strip.gsub(
#   /\[|\]|,/, ''
# ).split(' ')

config.groups = Dir.children(config.group_vars).map { |group| group.gsub('.yml', '') }
config.hosts = Dir.children(config.host_vars).map { |host| host.gsub('.yml', '') }
config.roles = Dir.children(config.roles_home)

ansible_project = AnsibleProject.new(config)
ui = UI.new(config)

playbook = ui.select_playbook(ansible_project)
type = ui.select_type

tags = case type
       when 'tags'
         ui.select_tags(playbook, ansible_project)
       when 'roles'
         ui.select_roles
       else
         []
       end

limit = ui.select_limit

group = case limit
        when 'groups'
          ui.select_group
        when 'hosts'
          ui.select_host
        when 'localhost'
          localhost = true
          config.inventory = File.join(config.ansible_home, 'hosts')
        else
          []
        end

command_parts = ['ansible-playbook', '-i', config.inventory, playbook]
command_parts << '--limit' << group.join(',') unless group.empty? || unless localhost
command_parts << '--tags' << tags.join(',') unless tags.empty?

CLI::UI.frame_style = :bracket

CLI::UI::StdoutRouter.enable

CLI::UI::Frame.open('syncopatedOS') do

  CLI::UI::Frame.open('Info') do
    puts command_parts
  end
  # Run Ansible Playbook
  CLI::UI::Frame.open('Output') do
    Dir.chdir(config.ansible_home) do
      Open3.popen3(command_parts.join(' ')) do |_stdin, stdout, stderr, _thread|
        # Capture stdout and stderr
        stdout_output = stdout.read
        stderr_output = stderr.read

        # Print stdout
        puts stdout_output

        # Check for errors
        if stderr_output.empty?
          puts 'Playbook executed successfully!'
        else
          puts 'Ansible Playbook encountered errors:'
          puts stderr_output
        end
      end
    end
  end
end
