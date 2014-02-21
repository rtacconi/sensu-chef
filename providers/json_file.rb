action :create do
  unless Sensu::JSONFile.compare_content(new_resource.path, new_resource.content)
    directory ::File.dirname(new_resource.path) do
      recursive true
      owner node['sensu']['admin']
      group "sensu"
      mode 0750
    end

    f = file new_resource.path do
      owner node['sensu']['admin']
      group "sensu"
      mode new_resource.mode
      content Sensu::JSONFile.dump_json(new_resource.content)
      notifies :create, "ruby_block[sensu_service_trigger]", :delayed
    end

    new_resource.updated_by_last_action(f.updated_by_last_action?)
  end
end

action :delete do
  f = file new_resource.path do
    action :delete
    notifies :create, "ruby_block[sensu_service_trigger]", :delayed
  end

  new_resource.updated_by_last_action(f.updated_by_last_action?)
end
