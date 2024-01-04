#!/usr/bin/env ruby
# frozen_string_literal: true

require 'cli/ui'
require 'yaml'
require 'json'
require 'csv'
require 'open4'
require "tty-prompt"


if ENV['ANSIBLE_HOME']
  ANSIBLE_HOME = ENV['ANSIBLE_HOME']
else
  ANSIBLE_HOME = File.expand_path('..', __dir__)
end

VARS = File.join(ANSIBLE_HOME, 'vars')
PLAYBOOKS = File.join(ANSIBLE_HOME, 'playbooks')
GROUP_VARS = File.join(ANSIBLE_HOME, 'group_vars')
HOST_VARS = File.join(ANSIBLE_HOME, 'host_vars')
ROLES = File.join(ANSIBLE_HOME, 'roles')
INVENTORY = File.join(ANSIBLE_HOME, 'inventory.ini')



class Ansible

  attr_accessor :inventory, :playbooks, :group_vars, :host_vars, :tags

  def initialize(location)
    @playbooks = Dir.children(PLAYBOOKS)
    @group_vars = File.join(location, 'group_vars')
    @host_vars = File.join(location, 'host_vars')
  end

  def tags(playbook)
    @tags = `ansible-playbook -i #{INVENTORY} #{playbook} --list-tags | awk -F 'TASK TAGS:' '{print $2}'`.chomp.strip.gsub(/\[|\]|,/,'')
  end


end

# select playbook


syncopated = Ansible.new(ANSIBLE_HOME)

p syncopated.playbooks

playbook = `gum filter #{Dir.children(PLAYBOOKS).join(' ')}`.chomp.strip
p playbook

tags = syncopated.tags(File.join(PLAYBOOKS, playbook))
p tags

t = `gum filter #{tags} --no-limit`.chomp.split("\n")

p t







CLI::UI::StdoutRouter.enable



CLI::UI::Frame.open('{{*}} {{bold:a}}', color: :green) do
  puts "hey fucker, select a playbook"
  puts "full playbook selected, retriveing tags"
  CLI::UI::Frame.open('{{i}} b', color: :magenta) do
    puts "select tags to run..."
    CLI::UI::Frame.open('{{?}} c', color: :cyan) do

      @distro = CLI::UI.ask('Select Distro', options: %w(Fedora Archlinux))

    end

  end

    CLI::UI::Frame.divider('{{v}} lol')

    puts "#{@distro}"

    packages = YAML.load_file(File.join(VARS, "#{@distro}", "packages.yml"))

    prompt = TTY::Prompt.new

    choice = prompt.multi_select("Select packages", packages["packages"]).flatten

    t = `gum filter #{choice.join(' ')} --no-limit`.chomp.split("\n")

    p t

end


def test(arg)
  puts "hey fucker"
end

CLI::UI::Frame.open('{{i}} b', color: :magenta) do

  CLI::UI::Prompt.ask('What language/framework do you use?') do |handler|
    handler.option('rails')  { |selection| test(selection) }
    handler.option('go')     { |selection| selection }
    handler.option('ruby')   { |selection| selection }
    handler.option('python') { |selection| selection }
  end

end

CLI::UI::Progress.progress do |bar|
  100.times do
    bar.tick
  end
end

CLI::UI::SpinGroup.new do |spin_group|
  spin_group.add('Title')   { |spinner| `ansible-playbook -C -i /home/b08x/Workspace/syncopatedIaC/inventory.ini /home/b08x/Workspace/syncopatedIaC/playbooks/full.yml --limit lapbot --tags desktop` }
  spin_group.add('Title 2') { |spinner| sleep 3.0; spinner.update_title('New Title'); sleep 3.0 }
end
