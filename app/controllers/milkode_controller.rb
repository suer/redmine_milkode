require 'milkode/cdweb/lib/database'
require 'milkode/findgrep/findgrep'

class MilkodeController < ApplicationController
  unloadable

  before_filter :find_project

  def index
    @package_num = Database.instance.yaml_package_num

    @keyword = params[:keyword]
    unless @keyword.blank?
      option = FindGrep::FindGrep::DEFAULT_OPTION.dup
      option.dbFile = Dbdir.groonga_path(Dbdir.default_dir) 
      @name_map = repository_package_map
      option.packages = @name_map.keys
      findGrep = FindGrep::FindGrep.new(@keyword, option)
      @results = []
      findGrep.pickupRecords.each do |record|
        @results << search_result(record)
      end
    end
  end

  private
  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end 

  def repository_package_map
    @project.repositories.inject({}) do |h, repository|
      h[package_name(repository)] = repository.identifier
      h
    end
  end

  def package_name(repository)
    url = repository.url
    url.sub!(/\.git$/,"") if repository.type == 'Repository::Git'
    File.basename(url)
  end

  def search_result(record)
    {
      :repository_identifier => repository_identifier(record[:shortpath]),
      :path => filepath(record[:shortpath])
    }
  end

  def repository_identifier(path)
    @name_map[path.split(File::SEPARATOR).first]
  end

  def filepath(path)
    path.split(File::SEPARATOR)[1..-1].join('/')
  end
end
