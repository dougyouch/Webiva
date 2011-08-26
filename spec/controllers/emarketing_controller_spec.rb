require "spec_helper"
require 'domain_log_spec_helper'

describe EmarketingController do
  render_views

  before(:each) do
    mock_editor
    Factory.create :domain_log_entry
    Factory.create :domain_log_entry
  end

  it "should render the index page" do
    get :index
    response.status.should == 200
  end

  it "should render the visitors page" do
    get :visitors
    response.status.should == 200
  end

  it "should render the referrer_sources page" do
    get :referrer_sources
    response.status.should == 200
  end

  it "should render the stats page" do
    get :stats
    response.status.should == 200
  end

  it "should render the affiliates page" do
    session = Factory.create :domain_log_session, :affiliate => 'webiva'
    entry = Factory.create :domain_log_entry, :domain_log_session_id => session.id
    entry = Factory.create :domain_log_entry, :domain_log_session_id => session.id
    get :affiliates
    response.status.should == 200
  end

  it "should render the real_time_stats_request page" do
    get :real_time_stats_request
    response.status.should == 200
  end

  it "should render the real_time_charts_request page" do
    get :real_time_charts_request
    response.status.should == 200
  end

  it "should handle visitor list" do
    # Test all the permutations of an active table
      controller.should handle_active_table(:visitor_table) do |args|
      post 'visitor_update', args
    end
  end

  it "should render the visitor_detail" do
    entry = Factory.create :domain_log_entry
    get :visitor_detail, :path => [entry.domain_log_session.domain_log_visitor_id]
    response.status.should == 200
  end
end
