require 'spec_helper'

describe Forge::Project do

  let(:project) { Forge::Project.new('/tmp/', { id: 'hello' }) }

  describe :config_file do
    it "should create an expanded path to the config file" do
      project.config_file.to_s.should == '/tmp/config.rb'
    end
  end

  describe :assets_path do
    it "should create an expanded path to the assets folder" do
      project.assets_path.to_s.should == '/tmp/source/assets'
    end
  end

  describe :build_dir do
    it "should create an expanded path to the forge build directory" do
      project.build_path.to_s.should == '/tmp/.forge/build'
    end
  end

end
