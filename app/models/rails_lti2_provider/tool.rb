module RailsLti2Provider
  class Tool < ActiveRecord::Base
    validates_presence_of :shared_secret, :uuid, :tool_settings, :lti_version
    serialize :tool_settings
    has_many :lti_launches
    has_many :registrations

    belongs_to :account, class_name: 'Account', foreign_key: 'account_id'

    def tool_proxy
      IMS::LTI::Models::ToolProxy.from_json(tool_settings)
    end

  end
end
