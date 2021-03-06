# frozen_string_literal: true

module V0
  module VIC
    class VICSubmissionsController < BaseController
      skip_before_action(:authenticate)

      def create
        authenticate_token

        vic_submission = ::VIC::VICSubmission.new(
          params.require(:vic_submission).permit(:form)
        )
        vic_submission.user = current_user unless vic_submission.process_as_anonymous?

        unless vic_submission.save
          Raven.tags_context(validation: 'vic')

          raise Common::Exceptions::ValidationErrors, vic_submission
        end

        clear_saved_form('VIC')

        render(json: vic_submission)
      end

      def show
        render(json: ::VIC::VICSubmission.find_by(guid: params[:id]))
      end
    end
  end
end
