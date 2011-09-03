# Copyright (C) 2009 Pascal Rettig.




class WebivaModuleGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :name, :type => :string

  attr_accessor :class_title, :class_name

  def copy_config_files
    @name = name.underscore
    @class_name = @name.classify
    @class_title = @class_name.underscore.humanize.titleize

    copy_file "init.rb", "vendor/modules/#{@name}/init.rb"
      
    empty_directory "vendor/modules/#{@name}/app/controllers/#{@name}"
    empty_directory "vendor/modules/#{@name}/app/models"
    empty_directory "vendor/modules/#{@name}/app/views/#{@name}/admin"
      
    template "admin_controller.rb", "vendor/modules/#{@name}/app/controllers/#{@name}/admin_controller.rb"
    template "options.rhtml", "vendor/modules/#{@name}/app/views/#{@name}/admin/options.rhtml"
  end
end
