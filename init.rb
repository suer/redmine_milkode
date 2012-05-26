Redmine::Plugin.register :milkode do
  name 'Milkode plugin'
  author 'mallowlabs'
  description 'This is a milkode plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/mallowlabs/redmine_milkode'
  author_url 'https://github.com/mallowlabs/'

  permission :milkode, {:milkode => [:index]}, :public => true
  menu :project_menu, :milkode, { :controller => 'milkode', :action => 'index' }, :caption => :milkode, :last => true, :param => :project_id
end
