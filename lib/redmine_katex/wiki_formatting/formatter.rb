# frozen_string_literal: true

module RedmineKatex
  module WikiFormatting
    # An isolated CommonMark formatter that differs from Redmine's built-in
    # formatter only by enabling CommonMarker's math_dollars extension and by
    # preserving the resulting data-math-style attribute.
    #
    # The built-in `common_mark` formatter and its constants are never modified.
    class Formatter < Redmine::WikiFormatting::CommonMark::Formatter
      BASE_CONFIG = Redmine::WikiFormatting::CommonMark::PIPELINE_CONFIG

      KATEX_EXTENSIONS = BASE_CONFIG.fetch(:commonmarker_extensions).merge(
        math_dollars: true
      ).freeze

      PIPELINE_CONFIG = BASE_CONFIG.merge(
        commonmarker_extensions: KATEX_EXTENSIONS
      ).freeze

      SANITIZER = begin
        sanitizer = Redmine::WikiFormatting::CommonMark::SanitizationFilter.new
        attrs = sanitizer.allowlist.fetch(:attributes)
        span_attrs = Array(attrs['span']).dup
        span_attrs << 'data-math-style' unless span_attrs.include?('data-math-style')
        attrs['span'] = span_attrs.freeze
        sanitizer
      end

      def to_html(*_args)
        html = Redmine::WikiFormatting::CommonMark::MarkdownFilter.new(@text, PIPELINE_CONFIG).call
        fragment = Redmine::WikiFormatting::HtmlParser.parse(html)
        SANITIZER.call(fragment)

        scrubbers = Redmine::WikiFormatting::CommonMark::SCRUBBERS + post_processor_scrubbers
        scrubber = Loofah::Scrubber.new do |node|
          scrubbers.each do |candidate|
            result = candidate.scrub(node)
            break result if result == Loofah::Scrubber::STOP
            break if node.parent.nil?
          end
        end

        fragment.scrub!(scrubber)
        fragment.to_s
      end
    end
  end
end
