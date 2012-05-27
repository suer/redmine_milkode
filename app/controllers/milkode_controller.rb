require 'milkode/cdweb/lib/database'
require 'milkode/findgrep/findgrep'

class MilkodeController < ApplicationController
  unloadable

  def index
    @package_num = Database.instance.yaml_package_num
  end

  def search
    @keyword = params[:keyword]
    option = FindGrep::FindGrep::DEFAULT_OPTION.dup
    option.dbFile = Dbdir.groonga_path(Dbdir.default_dir) 
    findGrep = FindGrep::FindGrep.new(@keyword, option)
    @records = findGrep.pickupRecords
  end
end
