# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V0::PreferencesController, type: :controller do
  include RequestHelper

  describe '#show' do
    context 'when not logged in' do
      it 'returns unauthorized' do
        get :show
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when logged in as an LOA1 user' do
      include_context 'login_as_loa1'
      let(:preference) { create(:preference, :with_choices) }

      before(:each) do
        login_as_loa1
        get :show, preference: preference.code
      end

      it 'returns successful http status' do
        expect(response).to have_http_status(:success)
      end

      it 'returns a single Preference' do
        preference_code = json_body_for(response)['attributes']['code']

        expect(preference_code).to eq preference.code
      end

      it 'returns all PreferenceChoices for a given Preference' do
        preference_choices = json_body_for(response)['attributes']['preference_choices']
        preference_choice_ids = preference_choices.map { |pc| pc['id'] }

        expect(preference_choice_ids).to match_array preference.choices.ids
      end
    end
  end
end
