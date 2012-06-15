Redmine::Plugin.register :redmine_milkode do
  name 'Milkode plugin'
  author 'suer'
  description 'This is a milkode plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/suer/redmine_milkode'
  author_url 'https://github.com/suer/'

  project_module :milkode do
    permission :milkode, {:milkode => [:index]}, :public => true
    menu :project_menu, :milkode, { :controller => 'milkode', :action => 'index' }, :caption => :milkode
  end
end
