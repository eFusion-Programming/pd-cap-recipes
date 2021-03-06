require 'spec_helper'

describe "Git sanity check", :recipe => true do
  it "should not ask for a tag when doing a restart" do
    config.find_and_execute_task('deploy:restart')
  end

  describe 'branch check', :tag => true do
    describe "with a current_revision" do
      before(:each) do
        config.set :current_revision, '1'
      end

      let(:task_lambda) {lambda { config.find_and_execute_task 'git:validate_branch_is_tag' }}

      it "should complain is the branch variable get overridden" do
        config.set :branch, 'release'
        task_lambda.should raise_error(Capistrano::Error)
      end

      it "should not complain is the branch variable get overridden" do
        task_lambda.should_not raise_error
      end

      ["deploy", "deploy:migrations"].each do |task|
        it "should run before #{task}" do
          before_callbacks_for_task(task).should include('git:validate_branch_is_tag')
        end
      end
    end

    describe 'without a current revision' do
      before(:each) do
        config.set :current_revision, lambda { raise 'Error like capistrano' }
      end

      it "should return the branch without exception" do
        config.branch   
      end
    end
  end
end

