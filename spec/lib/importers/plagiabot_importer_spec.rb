require 'rails_helper'
require "#{Rails.root}/lib/importers/plagiabot_importer"

describe PlagiabotImporter do
  describe '.check_recent_revisions' do
    it 'should save ithenticate_id for recent suspect revisions' do
      # This is a revision in the plagiabot database, although the date is not
      # 1.day.ago
      create(:revision,
             mw_rev_id: 678763820,
             article_id: 123321,
             date: 1.day.ago)
      create(:article,
             id: 123321,
             namespace: 0)
      PlagiabotImporter.check_recent_revisions
      rev = Revision.find_by(mw_rev_id: 678763820)
      expect(rev.ithenticate_id).to eq(19201081)
    end
  end

  describe '.api_get_url' do
    it 'returns an ithenticate report url for an ithenticate_id' do
      report_url = PlagiabotImporter.api_get_url(ithenticate_id: 19201081)
      url_match = report_url.include?('https://api.ithenticate.com/')
      # plagiabot may have an authentication error with ithenticate, in
      # which case it returns ';-(' as an error message in place of a url.
      # See also: https://github.com/valhallasw/plagiabot/issues/7
      if report_url.include?(';-(')
        puts 'WARNING: plagiabot returned an ithenticate-related error code'
      else
        expect(url_match).to eq(true)
      end
    end
  end

  describe '.find_recent_plagiarism' do
    it 'should save ithenticate_id for recent suspect revisions' do
      # This is tricky to test, because we don't know what the recent revisions
      # will be. So, first we have to get one of those revisions.
      suspected_diff = PlagiabotImporter
                       .api_get('suspected_diffs')[0]['diff'].to_i
      expect(suspected_diff.class).to eq(Fixnum)
      create(:revision,
             mw_rev_id: suspected_diff,
             article_id: 1123322,
             date: 1.day.ago)
      create(:article,
             id: 123332,
             namespace: 0)
      PlagiabotImporter.find_recent_plagiarism
      expect(Revision.find_by(mw_rev_id: suspected_diff).ithenticate_id).not_to be_nil
    end
  end

  describe 'error handling' do
    it 'handles connectivity problems gracefully' do
      stub_request(:any, /.*wmflabs.org.*/).and_raise(Errno::ETIMEDOUT)
      expect(PlagiabotImporter.api_get('suspected_diffs')).to be_nil
    end
  end
end
