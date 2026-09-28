# frozen_string_literal: true

require 'redmine'
require_relative 'lib/redmine_katex/hooks'

Redmine::Plugin.register :redmine_katex do
  name 'Redmine KaTeX'
  author 'Redmine Community'
  description 'Local KaTeX rendering with an isolated CommonMark + KaTeX formatter for Redmine 7.'
  version '1.1.1'
  url 'https://katex.org/'
  requires_redmine version_or_higher: '7.0.0'
end

# Register a separate formatter after Redmine has finished registering its own
# formatters. This avoids mutating CommonMark::PIPELINE_CONFIG, SANITIZER, or
# ApplicationHelper during boot.
Rails.application.config.after_initialize do
  begin
    require 'redmine/wiki_formatting/common_mark/formatter'
    require 'redmine/wiki_formatting/common_mark/helper'
    require 'redmine/wiki_formatting/common_mark/html_parser'
    require_relative 'lib/redmine_katex/wiki_formatting/formatter'

    unless Redmine::WikiFormatting.format_names.include?('common_mark_katex')
      Redmine::WikiFormatting.register(
        :common_mark_katex,
        RedmineKatex::WikiFormatting::Formatter,
        Redmine::WikiFormatting::CommonMark::Helper,
        Redmine::WikiFormatting::CommonMark::HtmlParser,
        label: 'CommonMark Markdown + KaTeX'
      )
    end

    Rails.logger.info '[redmine_katex] formatter common_mark_katex registered'
  rescue StandardError => e
    Rails.logger.error "[redmine_katex] formatter registration failed: #{e.class}: #{e.message}"
  end
end
