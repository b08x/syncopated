#!/usr/bin/env ruby
require 'cli/ui'
require 'yaml'
require 'json'
require 'csv'
require 'open4'
require "tty-prompt"

INVENTORY = '$ANSIBLE_HOME/hosts'
PLAYBOOK = '$ANSIBLE_HOME/soundbot.yml'

# module Ansible
#   module_function
#
#   def playbook(*args)
#     Soundbot::Command.tty("ansible-playbook -i #{INVENTORY} #{PLAYBOOK} #{args.join(' ')}")
#   end
#
#   def tags
#
#     tags = playbook("--list-tags")
#
#     return tags
#
#   end
#
#   def tasks
#
#     tasks = playbook("--list-tasks")
#
#     return tasks
#   end
#
#   def start_at_task(task)
#     playbook("--start-at-task=#{task}")
#   end
#
# end

#!/usr/bin/env ruby
# send osc messages to sonic-pi for every line printed when running a playbook
# https://stackoverflow.com/a/43208709/10073106

require 'open3'
require 'tty-progressbar'
bar = TTY::ProgressBar.new("importing [:bar] :elapsed :percent", total: 225 )


  Dir.chdir(File.join(ENV["HOME"], "Workspace", "syncopatedIaC")) do
    Open3.popen3 "ansible-playbook -C -i inventory.ini playbooks/full.yml --limit lapbot" do |stdin, stdout, stderr, thread|
      while line = stdout.gets
        # puts line
        # `oscsend localhost 4560 /test/thing s "#{line}"` if line.include?("TASK")
        bar.log("#{line.gsub(/\*/,'')}")
        bar.advance if line.include?("TASK")
      end
    end
  end
