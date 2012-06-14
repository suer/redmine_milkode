require 'coderay/encoders/html'
require 'milkode/cdweb/lib/database'
require 'milkode/findgrep/findgrep'
require 'milkode/cdweb/lib/grep'
require 'milkode/cdweb/lib/coderay_wrapper'

class MilkodeController < ApplicationController
  unloadable

  before_filter :find_project

  NTH = 3

  def index
    @keyword = params[:keyword]
    @page = (params[:page] || 1).to_i
    @per_page = (params[:per_page] || 10).to_i

    unless @keyword.blank?
      option = FindGrep::FindGrep::DEFAULT_OPTION.dup
      option.dbFile = Dbdir.groonga_path(Dbdir.default_dir)
      @name_map = repository_package_map
      option.packages = @name_map.keys
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

  MatchLine = Struct.new(:index)
  def search_result(record, patterns)
    match_indice = Grep.new(record.content).one_match_and(patterns)
    return nil unless match_indice

    match_line = MatchLine.new
    match_line.index = match_indice[0]

    start_index = match_indice[0] - NTH
    end_index = match_indice[0] + NTH
    coderay = CodeRayWrapper.new(record.content, record.shortpath, [match_line])
    coderay.set_range(start_index..end_index)
    {
      :repository_identifier => repository_identifier(record[:shortpath]),
      :path => filepath(record[:shortpath]),
      :content => coderay.to_html
    }
  end

  def repository_identifier(path)
    @name_map[path.split(File::SEPARATOR).first]
  end

  def filepath(path)
    path.split(File::SEPARATOR)[1..-1].join('/')
  end
end
