require 'spec_helper'


describe 'hf-lamp::web' do
  let (:chef_run) do
    ChefSpec::Runner.new do |node|
      node.automatic['hf-lamp']['sites'] = []
    end.converge(described_recipe)
  end

  apache2_binary =   

  before do
    stub_command('/usr/sbin/apache2 -t').and_return(true)
  end

  it 'should include the web_dependencies recipe' do
    expect(chef_run).to include_recipe('hf-lamp::web_dependencies')
  end

end
