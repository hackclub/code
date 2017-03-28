module Hackbot
  module SlackInteraction
    extend ActiveSupport::Concern

    def send_msg(channel, msg)
      opts = { as_user: true }

      if msg.is_a? String
        opts[:text] = msg
      else
        opts = opts.merge(msg)
      end

      if opts[:attachments]
        opts[:attachments] = insert_attachment_defaults(opts[:attachments])
      end

      ::SlackClient::Chat.send_msg(channel, nil, access_token, opts)
    end

    def attach(channel, *attachments)
      send_msg(channel, attachments: attachments)
    end

    # Commenting because this method's name is somewhat confusing. Please rename
    # if you can think of something better.
    #
    # This method updates the message that triggered action with the passed in
    # message contents. It uses action's special response_url attribute to
    # update the source message without leaving a note in the user's Slack
    # client saying that the source message was edited, making the UX of the
    # edit much nicer.
    #
    # The whole behavior of response_url can be quite confusing and difficult to
    # understand -- the first thing to understand is that the request format is
    # different from regular Web API calls and, therefore, can't be used with
    # our current SlackClient implementation.
    #
    # Docs: https://api.slack.com/docs/message-buttons#overview
    def update_action_source(msg, action_event = event)
      if msg[:attachments]
        msg[:attachments] = insert_attachment_defaults(msg[:attachments])
      end

      payload = { token: access_token, **msg }

      RestClient::Request.execute(
        method: :post,
        url: action_event[:response_url],
        payload: payload.to_json
      )
    end

    def send_file(channel, filename, file)
      SlackClient::Files.upload(
        channel,
        filename,
        file,
        access_token
      )
    end

    private

    def insert_attachment_defaults(attachments)
      mutated = attachments.deep_dup

      mutated.each do |a|
        # Enable text formatting for all possible values by default
        #
        # Docs: https://api.slack.com/docs/message-formatting#message_formatting
        a[:mrkdwn_in] ||= %w(pretext text fields)

        insert_action_defaults!(a) if a[:actions]
      end

      mutated
    end

    def insert_action_defaults!(attachment)
      # Set callback_id to the current interaction id for attachments that
      # include actions. We don't actually use this anywhere, opting to use
      # our should_handle? method instead to figure out how to handle actions
      # (as of 2017-03-22, at least), but this is a required field for actions
      # to work so we must set it.
      attachment[:callback_id] ||= id

      attachment[:actions].each do |action|
        # Set actions to buttons by default to simplify action usage. As of
        # 2017-03-22, there aren't any other action types, but they may be
        # added in the future.
        action[:type] ||= 'button'

        # Simplify usage by setting a default name.
        action[:name] ||= 'default_name'
      end
    end
  end
end