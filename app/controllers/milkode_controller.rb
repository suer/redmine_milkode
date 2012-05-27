require 'milkode/cdweb/lib/database'

class MilkodeController < ApplicationController
  unloadable


  def index
    @package_num = Database.instance.yaml_package_num
  end

  def search
  end
end
