require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ModsController do

  describe '#show' do

    context 'via JSON' do

      before do
        @mod = Factory(:mod)
        get :show, :id => @mod.id, :format => 'json'
      end
      
      it "should redirect to the source" do
        response.should redirect_to(@mod.source)
      end
        
    end
    
  end

end
