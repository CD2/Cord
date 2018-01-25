# frozen_string_literal: true

namespace :cord_v2 do
  desc 'does the docs'
  task document_actions: :environment do
    require_dependency "#{::CordV2::Engine.root}/lib/action_writer.rb"
    ActionWriter.write_actions
  end
end
