require 'coderay/encoders/html'
require 'milkode/findgrep/findgrep'
require 'milkode/cdweb/lib/grep'
require 'milkode/cdweb/lib/coderay_wrapper'

class MilkodeController < ApplicationController
  include MilkodeHelper
  unloadable

  before_filter :find_project

  NTH = 3

  def index
    @keyword = params[:keyword]
    @page = (params[:page] || 1).to_i
    @per_page = (params[:per_page] || 10).to_i

    unless @keyword.blank?
      option = FindGrep::FindGrep::DEFAULT_OPTION.dup
      option.dbFile = Dbdir.groonga_path(db_dir)

      option.packages = packages(@project)

      findGrep = FindGrep::FindGrep.new(@keyword.split, option)
      records = findGrep.pickupRecords

      @results = []
      records.each do |record|
        result = search_result(record, @keyword.split)
        @results << result if result
      end

      @total = @results.size
      @start_index = (@page - 1) * @per_page
      @end_index = [@total, @page * @per_page].min
      @results = @results[@start_index .. @end_index]
      @end_index -= 1 unless @end_index == 0
    end
  end

  def settings
    @repository_and_existences = @project.repositories.map do |repository|
      {:repository => repository, :package_exists => package_exists(@project.identifier, repository.identifier)}
    end
  end

  def add_repository
    project_id = @project.identifier
    identifier = params[:identifier]

    repository = @project.repositories.find { |r| r.identifier == identifier }
    
    add_package(project_id, identifier, repository.url, repository.scm_name)

    flash[:notice] = l(:notice_successful_create)
    redirect_to :action => :settings
  end

  def update_repository
    project_id = @project.identifier
    identifier = params[:identifier]

    repository = @project.repositories.find { |r| r.identifier == identifier }
    
    update_package(project_id, identifier, repository.url, repository.scm_name)

    flash[:notice] = l(:notice_successful_update)
    redirect_to :action => :settings
  end

  def delete_repository
    project_id = @project.identifier
    identifier = params[:identifier]

    repository = @project.repositories.find { |r| r.identifier == identifier }
    
    delete_package(project_id, identifier, repository.url, repository.scm_name)

    flash[:notice] = l(:notice_successful_delete)
    redirect_to :action => :settings
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

  def search_result(record, patterns)
    match_lines = Grep.new(record.content).match_lines_and(patterns)
    return nil if match_lines.size == 0

    start_index = match_lines[0].index - NTH
    end_index = match_lines[0].index + NTH
    coderay = CodeRayWrapper.new(record.content, record.shortpath, match_lines)
    coderay.set_range(start_index..end_index)
    {
      :repository_identifier => repository_identifier(record[:shortpath]),
      :path => filepath(record[:shortpath]),
      :content => coderay.to_html
    }
  end

  def repository_identifier(path)
    identifier_from_package_name(path.split(File::SEPARATOR).first)
  end

  def filepath(path)
    path.split(File::SEPARATOR)[1..-1].join('/')
  end
end
