# frozen_string_literal: true

module RedmineKatex
  module WikiFormatting
    # An isolated CommonMark formatter for display math.
    #
    # CommonMarker's math_dollars extension is enabled so that $$...$$ is
    # protected before ordinary Markdown escaping can alter TeX commands such
    # as \,. The same extension also recognizes $...$ as inline math, but this
    # plugin intentionally does not support inline dollar math: inline math
    # nodes are converted back to literal $...$ text before sanitization.
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

        # `math_dollars` recognizes both $...$ and $$...$$. v1.0.1 deliberately
        # supports display math only, so restore inline math to literal text.
        fragment.css('span[data-math-style="inline"]').each do |node|
          node.replace(Nokogiri::XML::Text.new("$#{node.text}$", fragment.document))
        end

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
