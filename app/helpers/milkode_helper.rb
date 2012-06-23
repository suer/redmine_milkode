require 'milkode/cdstk/cdstk'
require 'open3'

module MilkodeHelper
  def add_package(project_id, identifier, url, scm)
    # specify clone directory
    repository_dir = repository_path(project_id, identifier)

    # clone command
    cmd = clone_command(repository_dir, url, scm)

    # clone repositories into tmporary dir
    if cmd
      Open3.popen3(cmd) do |stdin,stdout,stderr|
        puts stdout.gets
        puts stderr.gets
      end

      # add to milkode
      Milkode::Cdstk.new($stdout, db_dir).add([repository_dir], {})
    end
  end

  def update_package(project_id, identifier, url, scm)
    delete_package(project_id, identifier, url, scm)
    add_package(project_id, identifier, url, scm)
  end

  def delete_package(project_id, identifier, url, scm)
    # delete from repositories
    Milkode::Cdstk.new($stdout, db_dir).remove([make_package_name(project_id, identifier)], {})

    # remove from milkode
    FileUtils.rm_r([repository_path(project_id, identifier)])
  end

  def package_exists(project_id, identifier)
    File.exist?(repository_path(project_id, identifier))
  end

  def tmp_milkode_db_path
    path = File.join(tmp_milkode_path, 'db')
    unless File.exist?(path)
      FileUtils.mkdir_p(path)
      init_db(path)
    end
    path
  end
  alias :db_dir :tmp_milkode_db_path

  def packages(project)
    project.repositories.map do |r|
      package = ""
      unless r.identifier.blank?
        package << r.identifier
        package << '@'
      end
      package << project.identifier
      package
    end
  end

  private
  # milk init
  def init_db(db_path)
    Milkode::Cdstk.new($stdout, db_path).init({})
  end

  def repository_path(project_id, identifier)
    File.join(tmp_milkode_repositories_path, make_package_name(project_id, identifier))
  end

  def make_package_name(project_id, identifier)
     return project_id if identifier.blank?
    "#{identifier}@#{project_id}"
  end

  def tmp_path(root = Rails.root.to_s)
    File.join(root, 'tmp') 
  end

  def tmp_milkode_path
    create_unless_exist(File.join(tmp_path, 'milkode'))
  end

  def tmp_milkode_repositories_path
    create_unless_exist(File.join(tmp_milkode_path, 'repositories'))
  end

  def create_unless_exist(path)
    FileUtils.mkdir_p(path) unless File.exist?(path)    
    path
  end

  def clone_command(repository_dir, url, scm)
    cmd = nil
    if scm == Repository::Git.scm_name
      git_bin = Redmine::Scm::Adapters::GitAdapter::client_command
      cmd = "#{git_bin} clone #{url} #{repository_dir}"
    elsif scm == Repository::Subversion.scm_name
      svn_bin = Redmine::Scm::Adapters::SubversionAdapter::client_command
      cmd = "#{svn_bin} export #{url} #{repository_dir}"
      cmd << "@" if repository_dir =~ /@/
    end
    cmd
  end
end
