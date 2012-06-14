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
    @package_num = Database.instance.yaml_package_num

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

      @total = records.size
      @start_index = (@page - 1) * @per_page
      @end_index = [@total, @page * @per_page].min
      @end_index -= 1 unless @end_index == 0

      @results = []
      records[@start_index..@end_index].each do |record|
        @results << search_result(record, @keyword.split)
      end
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

  def search_result(record, patterns)
    match_lines = Grep.new(record.content).match_lines_and(patterns)
    content = "<pre>" + record.content + "</pre>"
    if match_lines.size > 0
      start_index = match_lines[0].index - NTH
      end_index = match_lines[0].index + NTH
      coderay = CodeRayWrapper.new(record.content, record.shortpath, match_lines)
      coderay.set_range(start_index..end_index)
      content = coderay.to_html
    end
    {
      :repository_identifier => repository_identifier(record[:shortpath]),
      :path => filepath(record[:shortpath]),
      :content => content
    }
  end

  def repository_identifier(path)
    @name_map[path.split(File::SEPARATOR).first]
  end

  def filepath(path)
    path.split(File::SEPARATOR)[1..-1].join('/')
  end
end
