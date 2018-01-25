# frozen_string_literal: true

AbstractController::Base.send :include, CordV2::ApplicationHelper
CordV2.action_writer_path = Rails.root.join 'actions.md'
CordV2.enable_postgres_rendering = true
