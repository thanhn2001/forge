require 'spec_helper'

describe Forge::Guard do

  let(:project) { Forge::Project.new('/tmp/', {name: 'Hello'}) }
  let(:guard) { Forge::Guard.new(project, nil) }

  subject { guard }

  describe '#identify_file' do
    it 'should properly identify the functions.php file' do
      subject.identify_file("/Users/jason/Projects/walmart-labs-site/source/functions/functions.php").should eql :function
    end
  end

end
