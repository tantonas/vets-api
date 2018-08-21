# frozen_string_literal: true

require 'faker'

class SubmitFormDataGenerator
  A = Faker::Address
  I = Faker::Internet
  L = Faker::Lorem
  N = Faker::Name
  NUM = Faker::Number

  def initialize
    @form_data = compact(
      'form526' => {
        'veteran' => veteran,
        'mililtaryPayments' => military_payments,
        'serviceInformation' => service_information,
        'disabilities' => disabilities,
        'treatments' => treatments,
        'specialCircumstances' => special_circumstances,
        'standardClaim' => random_bool,
        'claimantCertification' => true
      }
    )
  end

  def to_hash
    @form_data
  end

  def to_json
    @form_data.to_json
  end

  private

  def compact(hash)
    p = proc do |*args|
      v = args.last
      v.delete_if(&p) if v.respond_to? :delete_if
      v.nil? || v.respond_to?(:"empty?") && v.empty?
    end

    hash.delete_if(&p)
  end

  def veteran
    {
      'emailAddress' => I.email,
      'alternateEmailAddress' => (I.email if random_bool),
      'mailingAddress' => address,
      'forwardingAddress' => (address.merge('effectiveDate' => date) if random_bool),
      'primaryPhone' => NUM.number(10),
      'homelessness' => homelessness(random_bool),
      'serviceNumber' => (NUM.number(9) if random_bool)
    }
  end

  def military_payments
    if random_bool
      {
        'payments' => [{
          'payType' => pay_type,
          'amount' => NUM.number(5)
        }],
        'receiveCompensationInLieuOfRetired' => random_bool
      }
    end
  end

  def service_information
    si = {
      'servicePeriods' => [{
        'serviceBranch' => service_branch,
        'dateRange' => date_range('service')
      }],
      'servedInCombatZone' => random_bool,
      'confinements' => (
      if random_bool
        [{
          'confinementDateRange' => date_range,
          'verifiedIndicator' => random_bool
        }]
      end)
    }

    if random_bool
      si.merge(separation_location)
    else
      si
    end
  end

  def separation_location
    {
      'separationLocationName' => 'Langley Air Force Base',
      'separationLocationCode' => '98283'
    }
  end

  def disabilities
    # NB: this is hard-coded specifically for the user vets.gov.user+14@gmail.com
    [{
      'name' => 'Post Traumatic Stress Disorder',
      'disabilityActionType' => 'INCREASE',
      'ratedDisabilityId' => '1065375',
      'ratingDecisionId' => '83674',
      'diagnosticCode' => 9411,
    }]
  end

  def treatments
    if random_bool
      [{
        'treatmentCenterName' => L.word,
        'treatmentDateRange' => date_range,
        'treatmentCenterAddress' => address.slice('country', 'city', 'state'),
        'treatmentCenterType' => treatment_center_type
      }]
    end
  end

  def special_circumstances
    if random_bool
      [{
        'name' => L.word,
        'code' => L.word,
        'needed' => random_bool
      }]
    end
  end

  def reserves_national_guard_service
    if random_bool
      {
        'title10Activation' => (
        if random_bool
          {
            'title10ActivationDate' => date,
            'anticipatedSeparationDate' => date
          }
        end),
        'obligationTermOfServiceDateRange' => date_range,
        'unitName' => L.word,
        'waiveVABenefitsToRetainTrainingPay' => random_bool
      }
    end
  end

  def homelessness(homeless)
    {
      'isHomeless' => homeless,
      'pointOfContact' => (
      if homeless
        {
          'pointOfContactName' => "#{N.first_name} #{N.last_name}",
          'primaryPhone' => NUM.number(10)
        }
      end)
    }
  end

  def random_bool
    [true, false].sample
  end

  def address
    {
      'addressLine1' => A.street_address.truncate(19),
      'addressLine2' => (A.secondary_address.truncate(19) if random_bool),
      'city' => A.city,
      'state' => A.state_abbr,
      'zipCode' => A.zip,
      'country' => 'USA'
    }
  end

  # rubocop:disable all
  def date
    '2017-01-02'
    # DateTime.parse(Faker::Date.between(Date.today - 365, Date.today - 182).to_s)
  end

  def from_date
    '2018-01-01'
    # DateTime.parse(Faker::Date.between(Date.today - (2 * 365), Date.today - 365).to_s)
  end

  def service_from_date
    '2017-01-01'
    # DateTime.parse(Faker::Date.between(Date.today - (3 * 365), Date.today - (2 * 365)).to_s)
  end

  def service_to_date
    '2018-01-02'
    # DateTime.parse(Faker::Date.between(Date.today - 182, Date.today).to_s)
  end
  # rubocop:enable all

  def date_range(type = nil)
    if type == 'service'
      {
        'from' => service_from_date,
        'to' => service_to_date
      }
    else
      {
        'from' => from_date,
        'to' => date
      }
    end
  end

  def pay_type
    %w[LONGEVITY TEMPORARY_DISABILITY_RETIRED_LIST PERMANENT_DISABILITY_RETIRED_LIST SEPARATION SEVERANCE].sample
  end

  def service_branch
    [
      'Air Force',
      'Air Force Reserves',
      'Air National Guard',
      'Army',
      'Army National Guard',
      'Army Reserve',
      'Coast Guard',
      'Coast Guard Reserve',
      'Marine Corps',
      'Marine Corps Reserve',
      'NOAA',
      'Navy',
      'Navy Reserve',
      'Public Health Service'
    ].sample
  end

  def treatment_center_type
    %w[VA_MEDICAL_CENTER DOD_MTF].sample
  end
end