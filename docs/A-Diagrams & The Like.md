# diagrams

```bash
/*
                                 ┌─────────────────────────────────────────┐
    hydrogen ◄───┐               │                                         │
                 │               │   templates   scripts     patches       │
                 │               │                                         │
    helm  ◄──────┼───────────────┤                                         │
                 │               │                                         │
                 │               │                                         │
    linuxsam ◄───┘               │            git repo                     │
                             ┌───┤                                         │
                             │   └────-────────────────────────────────────┘
                             │        
                             │        
                             │        
                             ▼                                    Untitled drawing
                             │        
    ┌───────────────┬────────┼────────┼───────────┬──────────────┬─────────────┐
    │               │        │        │           │              │             │
    │               │        │        │           │              │             │
    │               │        │        │           ▼              ▼             ▼
    ▼               ▼        │        ▼
audacity          reaper     │    bitwig        vst3        ambisonics        lv2
                             │
                             │
                             │
                             └───►  sonic pi

                                    jacktrip
 */
```


---

```shell

                                                            ┌─────────────┐
                                                            │             │
                                              ┌────────────►│   lapbot    │
                                              │             │             │
                                              │             └─────────────┘
                                              │
                   ┌──────────────┐           │
                   │              │           │
                   │   soundbot   ├───────────┤
                   │              │           │
                   └─────┬────────┘           │        ┌────────┐
                         │                    │        │        │
                         │                    │        │ bender │
                         │                    └───────►│        │
                         │                             │        │
                         │                             └────────┘
                         │
                         │                  ┌────────┐
     ┌─────────┐         │                  │        │
     │         │         │                  │ bigbot │
     │ tinybot │◄────────┴─────────────────►│        │
     │         │                            │        │
     └─────────┘                            │        │
                                            └────────┘
 
```

```json

"example/group_vars/all.yml"

{"user"=>{"name"=>"b08x", "realname"=>"Robert Pannick", "group"=>"b08x", "uid"=>1000, "gid"=>1000, "secondary_groups"=>"input,video,audio", "sudoers"=>true, "home"=>"/home/b08x", "workspace"=>"/home/b08x/Workspace", "shell"=>"/usr/bin/zsh", "email"=>"rwpannick@gmail.com", "gpg"=>"36A6ECD355DB42B296C0CEE2157CA2FC56ECC96A", "dots"=>"git@github.com:b08x/dots.git"}, 

"users"=>[
  {"name"=>"root", "group"=>"root", "uid"=>0, "gid"=>0, "home"=>"/root", "shell"=>"/usr/bin/zsh"}, 
  {"name"=>"b08x", "realname"=>"Robert Pannick", "group"=>"b08x", "uid"=>1000, "gid"=>1000, "secondary_groups"=>"input,video,audio", "sudoers"=>true, "home"=>"/home/b08x", "workspace"=>"/home/b08x/Workspace", "shell"=>"/usr/bin/zsh", "email"=>"rwpannick@gmail.com", "gpg"=>"36A6ECD355DB42B296C0CEE2157CA2FC56ECC96A", "dots"=>"git@github.com:b08x/dots.git"}], 
  
"autofs_client"=>{"host"=>"bender", "shares"=>["backup", "storage"]}, 

"docker"=>{"storage"=>"/var/lib/docker", "service"=>{"enabled"=>true}, "nvidia"=>false, "users"=>["b08x"]}, 


data = { 
  "libvirt"=> { 
    "service"=> {
      "enabled"=>false
      }, 
    "users"=> ["b08x"]
    }
}

table = Terminal::Table.new do |t|
  t.title = "User Information"
  t.headings = ["Key", "Value"]
  data["libvirt"].each do |key, value|
    t.add_row([key, value])
  end
end


"example/group_vars/server.yml"
No Variables in example/group_vars/server.yml

"example/group_vars/workstation.yml"
No Variables in example/group_vars/workstation.yml


+---------------------------------------------------------------------------------------------------------------------------->>
|            File            |      Key      |                                                                               >>
+---------------------------------------------------------------------------------------------------------------------------->>
| example/group_vars/all.yml | user          | {"name"=>"b08x", "realname"=>"Robert Pannick", "group"=>"b08x", "uid"=>1000, ">>
| example/group_vars/all.yml | users         | [{"name"=>"root", "group"=>"root", "uid"=>0, "gid"=>0, "home"=>"/root", "shell>>
| example/group_vars/all.yml | autofs_client | {"host"=>"bender", "shares"=>["backup", "storage"]}                           >>
| example/group_vars/all.yml | docker        | {"storage"=>"/var/lib/docker", "service"=>{"enabled"=>true}, "nvidia"=>false, >>
| example/group_vars/all.yml | libvirt       | {"service"=>{"enabled"=>false}, "users"=>["b08x"]}                            >>
+---------------------------------------------------------------------------------------------------------------------------->>

```

```ruby
require 'terminal-table'

data = {
  "user" => {
    "name" => "b08x",
    "realname" => "Robert Pannick",
    "group" => "b08x",
    "uid" => 1000,
    "gid" => 1000,
    "secondary_groups" => "input,video,audio",
    "sudoers" => true,
    "home" => "/home/b08x",
    "workspace" => "/home/b08x/Workspace",
    "shell" => "/usr/bin/zsh",
    "email" => "rwpannick@gmail.com",
    "gpg" => "36A6ECD355DB42B296C0CEE2157CA2FC56ECC96A",
    "dots" => "git@github.com:b08x/dots.git"
  }
}

table = Terminal::Table.new do |t|
  t.title = "User Information"
  t.headings = ["Key", "Value"]
  data["user"].each do |key, value|
    t.add_row([key, value])
  end
end

puts table

```


https://github.com/aplatform64/aplatform64

  

https://github.com/vvo/ansible-archee/blob/master/roles/base/vars/main.yml

---
