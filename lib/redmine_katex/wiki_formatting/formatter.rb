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

      class KatexSanitizationFilter < Redmine::WikiFormatting::CommonMark::SanitizationFilter
        def allowlist
          @katex_allowlist ||= begin
            list = super.deep_dup
            list[:attributes] ||= {}
            list[:attributes]['span'] = Array(list[:attributes]['span'])
            list[:attributes]['span'] << 'data-math-style' unless list[:attributes]['span'].include?('data-math-style')
            list.freeze
          end
        end
      end

      SANITIZER = KatexSanitizationFilter.new

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
