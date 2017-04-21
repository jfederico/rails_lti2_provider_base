module RailsLti2Provider
  class LtiLaunch < ActiveRecord::Base
    validates_presence_of :tool_id, :nonce
    belongs_to :tool
    serialize :message

    def self.check_launch(lti_message, code)
      if lti_message.lti_version == 'LTI-1p0'
        account = Account.find_by_code code
        tool = Tool.find_by(uuid: lti_message.oauth_consumer_key, account_id: account.id)
        raise Unauthorized.new(:account_not_found) unless tool
      else
        tool = Tool.find_by(uuid: lti_message.oauth_consumer_key)
      end
      raise Unauthorized.new(:invalid_signature) unless lti_message.valid_signature?(tool.shared_secret)
      raise Unauthorized.new(:invalid_nonce) if tool.lti_launches.where(nonce: lti_message.oauth_nonce).count > 0
      raise Unauthorized.new(:request_too_old) if  DateTime.strptime(lti_message.oauth_timestamp,'%s') < 5.minutes.ago
      tool.lti_launches.where('created_at > ?', 1.day.ago).delete_all
      tool.lti_launches.create(nonce: lti_message.oauth_nonce, message: lti_message.post_params)
    end

    def message
      IMS::LTI::Models::Messages::Message.generate(read_attribute(:message))
    end

    class Unauthorized < StandardError;
      attr_reader :error
      def initialize(error = :unknown)
        @error = error
      end
    end


  end
end
