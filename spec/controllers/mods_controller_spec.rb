require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ModsController do

  describe "#index" do

    context "via JSON, querying" do

      before do
        @mod1 = Factory(:mod, :name => 'foo')
        @mod2 = Factory(:mod, :name => 'bar', :namespace => @mod1.namespace)
        get :index, :q => @mod1.namespace.full_name
      end

      it "should return JSON" do
        response.should redirect_to(user_namespace_mods_url(@mod1.namespace.owner, @mod1.namespace, :format => 'json'))
      end

    end

  end

  describe '#show' do

    context 'via JSON' do

      context "without a nested route" do

        before do
          @mod = Factory(:mod)
        end

        context "with a query-style :id" do

          before do
            get :show, :id => @mod.full_name, :format => 'json'
          end
          
          it "should be redirected" do
            response.should redirect_to(user_namespace_mod_url(@mod.namespace.owner, @mod.namespace, @mod, :format => 'json'))
          end

        end

        context "without a query-style :id" do

          before do
            get :show, :id => @mod.id, :format => 'json'
          end

          it "should fail" do
            response.should_not be_success
          end

        end

      end

      context "with a nested route" do

        before do
          @mod = Factory(:mod)
          get :show, :namespace_id => @mod.namespace.to_param, :user_id => @mod.namespace.owner.to_param, :id => @mod.to_param, :format => 'json'
        end
        
        it "should be successful" do
          response.should be_success
        end

        it "should include json fields" do
          doc = JSON.parse(response.body)
          doc.should be_a_kind_of(Hash)
          doc['source'].should == @mod.source
          doc['name'].should == @mod.name
          doc['full_name'].should == @mod.full_name
        end

      end      
        
    end
    
  end

end
