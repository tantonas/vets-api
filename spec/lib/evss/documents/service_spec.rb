# frozen_string_literal: true

require 'rails_helper'

describe EVSS::Documents::Service do
  let(:current_user) { create(:evss_user) }
  let(:document_data) do
    EVSSClaimDocument.new(
      evss_claim_id: 600_118_851,
      file_name: 'doctors-note.pdf',
      tracked_item_id: nil,
      document_type: 'L023'
    )
  end

  subject { described_class.new(current_user) }

  context 'with headers' do
    it 'should upload documents' do
      VCR.use_cassette('evss/documents/upload_client', VCR::MATCH_EVERYTHING) do
        demo_file_name = "#{::Rails.root}/spec/fixtures/files/doctors-note.pdf"
        File.open(demo_file_name, 'rb') do |f|
          response = subject.upload(f, document_data)
          expect(response).to be_success
        end
      end
    end
  end
end