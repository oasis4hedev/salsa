require 'rails_helper'
require 'date'
require 'organization'

RSpec.describe ApplicationHelper, type: :helper do

  context "find_org_by_path" do
    let(:root_org) { FactoryBot.create(:organization, slug: root_url.gsub(/(http|:|\/)/,""), track_meta_info_from_document: true, lms_authentication_id: "3013371946") }
    let(:sub_org) { FactoryBot.create(:sub_organization, parent_id: root_org.id) }
    
    it "gets a root organization" do
      expect( find_org_by_path(root_org.slug)).to eq root_org
    end

    it "gets a sub organization" do
      expect( find_org_by_path("#{root_org.slug}#{sub_org.slug}")).to eq sub_org
    end

    it "fails to get a non-existent sub organization" do
      expect { find_org_by_path("#{root_org.slug}/bad_sub_org") }.to raise_error(ActiveRecord::RecordNotFound)
    end

  end

end
