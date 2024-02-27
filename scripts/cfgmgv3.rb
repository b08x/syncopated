#!/usr/bin/env ruby
# frozen_string_literal: true

require 'cli/ui'
require 'yaml'
require 'json'
require 'csv'
require 'open3'
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

TAGS = %(alsa always applications asdf audio autofs backgrounds backup barrier base bluetooth chaotic cheatsheets cleanup cpupower deadbeef desktop distro docker dots dunst env firewall fonts gnome-keyring groups grub gtk guake htop i3 icons input-remapper jack keybindings keys kitty libvirt lightdm lnav lsmi media menu menus midi mirrors mixxx mkinitcpio network nfs ntp ohmyzsh osc2midi packages pacman pam paru picom pipewire profile protokol pulsar pulseaudio python qt ranger realtime reaper redshift repo robotstuff rofi rsyncd rtirq rtkit ruby setup shell sonicannotator soniclineup ssh sshd sudoers sxhkd sysctl terminal testing texlive theme thunar tilda tony touchosc tui tuned tuning updatedb user vagrant vamp video vscode workstation x xdg zram)
GROUPS = %(workstation webhost server testing)

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
CLI::UI.frame_style = :bracket

CLI::UI::StdoutRouter.enable
CLI::UI::Frame.open('syncopatedIaC') do
  
  CLI::UI::Frame.open('Playbook') do 
    syncopated = Ansible.new(ANSIBLE_HOME)
    @playbook = `gum filter #{syncopated.playbooks.join(' ')}`.chomp
    puts "#{@playbook}"
  end
  CLI::UI::Frame.open('Tags') do 
    @tags = `gum filter --no-limit #{TAGS}`.chomp
    @tags.gsub!(/\n/,',')
  end
  CLI::UI::Frame.open('Group') do
    @group = `gum choose #{GROUPS}`.chomp
    @group.gsub!(/\n/,',')
  end  
end

Dir.chdir(File.join(ANSIBLE_HOME)) do
  Open3.popen3 "ansible-playbook -C -i inventory.ini playbooks/#{@playbook} --limit #{@group} --tags #{@tags}" do |stdin, stdout, stderr, thread|
    while line = stdout.gets
      CLI::UI::SpinGroup.new do |spin_group|
        if line.include?("TASK")
          spin_group.add(line.gsub(/\*+/,''))  {|spinner| sleep 0.0125 }
        end
        if line.match?(/ok|changed/)
          spin_group.add(line.gsub(/ok\:\s\[\]/,'')) {|spinner| sleep 0.0125 }
        end
      end
    end
  end
end

# CLI::UI::Frame.open('Frame 1') do
# CLI::UI::Spinner.spin("building packages: {{@widget/status:2:2:3:4}}") do |spinner|
#   sleep 3
#   begin
    
#       `fd -t f |fzf`
    
#   rescue StandardError => e
#     p e
#   ensure
#       spinner.update_title("compiling")
#       sleep 10
#       puts "build package 1"
#       spinner.update_title("testing")
#       sleep(2)
#       puts "execute command"
#       spinner.update_title("installing")
#       sleep(3)
#   end
# end
# end

# playbook = `gum filter #{Dir.children(PLAYBOOKS).join(' ')}`.chomp.strip
# p playbook


# t = `gum filter #{tags} --no-limit`.chomp.split("\n")

# p t







# CLI::UI::StdoutRouter.enable



# CLI::UI::Frame.open('{{*}} {{bold:a}}', color: :green) do
#   puts "hey fucker, select a playbook"
#   puts "full playbook selected, retriveing tags"
#   CLI::UI::Frame.open('{{i}} b', color: :magenta) do
#     puts "select tags to run..."
#     CLI::UI::Frame.open('{{?}} c', color: :cyan) do

#       @distro = CLI::UI.ask('Select Distro', options: %w(Fedora Archlinux))

#     end

#   end

#     CLI::UI::Frame.divider('{{v}} lol')

#     puts "#{@distro}"

#     packages = YAML.load_file(File.join(VARS, "#{@distro}", "packages.yml"))

#     prompt = TTY::Prompt.new

#     choice = prompt.multi_select("Select packages", packages["packages"]).flatten

#     t = `gum filter #{choice.join(' ')} --no-limit`.chomp.split("\n")

#     p t

# end


# def test(arg)
#   puts "hey fucker"
# end

# CLI::UI::Frame.open('{{i}} b', color: :magenta) do

#   CLI::UI::Prompt.ask('What language/framework do you use?') do |handler|
#     handler.option('rails')  { |selection| test(selection) }
#     handler.option('go')     { |selection| selection }
#     handler.option('ruby')   { |selection| selection }
#     handler.option('python') { |selection| selection }
#   end

# end

# CLI::UI::Progress.progress do |bar|
#   100.times do
#     bar.tick
#   end
# end

# CLI::UI::SpinGroup.new do |spin_group|
#   spin_group.add('Title')   { |spinner| `ansible-playbook -C -i /home/b08x/Workspace/syncopatedIaC/inventory.ini /home/b08x/Workspace/syncopatedIaC/playbooks/full.yml --limit lapbot --tags desktop` }
#   spin_group.add('Title 2') { |spinner| sleep 3.0; spinner.update_title('New Title'); sleep 3.0 }
# end
