require 'milkode/cdweb/lib/database'
require 'milkode/findgrep/findgrep'

class MilkodeController < ApplicationController
  unloadable

  before_filter :find_project

  def index
    @package_num = Database.instance.yaml_package_num
  end

  def search
    @keyword = params[:keyword]
    option = FindGrep::FindGrep::DEFAULT_OPTION.dup
    option.dbFile = Dbdir.groonga_path(Dbdir.default_dir) 
    option.packages = @project.repositories.map {|r| package_name(r)}
    findGrep = FindGrep::FindGrep.new(@keyword, option)
    @records = findGrep.pickupRecords
  end

  private
  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end 

  def package_name(repository)
    url = repository.url
    url.sub!(/\.git$/,"") if repository.type == 'Repository::Git'
    File.basename(url)
  end

end
