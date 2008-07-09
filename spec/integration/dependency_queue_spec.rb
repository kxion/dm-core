require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe "DataMapper::DependencyQueue" do
  before :each do
    @q = DataMapper::DependencyQueue.new
    @dependencies = @q.instance_variable_get("@dependencies")
  end

  describe "#initialize" do
    describe "@dependencies" do
      it "should be a hash after initialize" do
        @dependencies.should be_a_kind_of(Hash)
      end

      it "should set value to [] when new key is accessed" do
        @dependencies['New Key'].should == []
      end
    end
  end

  describe "#add" do
    it "should store the supplied callback in @dependencies" do
      @q.add('Zoo') { true }
      @dependencies['Zoo'].first.call.should == true
    end
  end

  describe "#resolve!" do
    describe "(when dependency is not defined)" do
      it "should not alter @dependencies" do
        @q.add('Zoo') { true }
        old_dependencies = @dependencies.dup
        @q.resolve!
        old_dependencies.should == @dependencies
      end
    end

    describe "(when dependency is defined)" do
      before :each do
        @q.add('Zoo') { |klass| klass.instance_variable_set("@resolved", true) } # add before Zoo is loaded

        class Zoo
        end
      end

      it "should execute stored callbacks" do
        @q.resolve!
        Zoo.instance_variable_get("@resolved").should == true
      end

      it "should clear @dependencies" do
        @q.resolve!
        @dependencies['Zoo'].should be_empty
      end
    end
  end

end
