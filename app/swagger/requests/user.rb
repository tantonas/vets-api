# frozen_string_literal: true

module Swagger
  module Requests
    class User
      include Swagger::Blocks

      swagger_path '/v0/user' do
        operation :get do
          extend Swagger::Responses::AuthenticationError

          key :description, 'Get user data'
          key :operationId, 'getUser'
          key :tags, [
            'user'
          ]

          parameter :authorization

          response 200 do
            key :description, 'get user response'
            schema do
              key :'$ref', :UserData
            end
          end
        end
      end

      swagger_schema :UserData, required: [:data] do
        allOf do
          schema do
            key :'$ref', :Vet360ContactInformation
          end
          schema do
            property :data, type: :object do
              property :id, type: :string
              property :type, type: :string
              property :attributes, type: :object do
                property :services, type: :array do
                  items do
                    key :type, :string
                  end
                end
                property :in_progress_forms
                property :profile, type: :object do
                  property :email, type: :string
                  property :first_name, type: :string
                  property :last_name, type: :string
                  property :birth_date, type: :string
                  property :gender, type: :string
                  property :zip, type: :string
                  property :last_signed_in, type: :string
                  property :loa, type: :object do
                    property :current, type: :integer, format: :int32
                    property :highest, type: :integer, format: :int32
                  end
                end
                property :va_profile, type: :object do
                  property :status, type: :string
                  property :birthdate, type: :string
                  property :family_name, type: :string
                  property :gender, type: :string
                  property :given_names, type: :array do
                    items do
                      key :type, :string
                    end
                  end
                end
                property :veteran_status, type: :object do
                  key :required, [:status]
                  property :is_veteran, type: :boolean, example: true
                  property :status, type: :string, enum: %w[OK NOT_AUTHORIZED NOT_FOUND SERVER_ERROR], example: 'OK'
                end
              end
            end
          end
        end
      end

      swagger_path '/v0/user/authorized/{policy}/{policy_action}' do
        operation :get do
          extend Swagger::Responses::AuthenticationError

          key :description, 'Evaluates a user against a policy action and reports reasons they may not be authorized'
          key :operationId, 'userAuthorizedForService'
          key :tags, [
            'user'
          ]

          parameter :authorization

          parameter do
            key :name, :policy
            key :in, :path
            key :description, 'The policy lookup name for the service'
            key :required, true
            key :type, :string
          end

          parameter do
            key :name, :policy_action
            key :in, :path
            key :description, 'The action to check within the policy'
            key :required, true
            key :type, :string
          end

          response 200 do
            key :description, 'user policy evaluation response'
            schema do
              key :'$ref', :ServiceAuthDetail
            end
          end
        end
      end
    end
  end
end
