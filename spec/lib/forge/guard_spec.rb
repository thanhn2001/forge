require 'spec_helper'

describe Xerox::Guard do

  let(:project) { Xerox::Project.new('/tmp/', {name: 'Hello'}) }
  let(:guard) { Xerox::Guard.new(project, nil) }

  subject { guard }

  describe '#identify_file' do
    it 'should properly identify the functions.php file' do
      subject.identify_file('/some-project/source/functions/functions.php').should eql :function
    end

    it 'should properly identify an image asset' do
      subject.identify_file('/some-project/source/assets/images/lol.png').should eql :asset
    end
  end

end
