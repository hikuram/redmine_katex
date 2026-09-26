# frozen_string_literal: true

module RedmineKatex
  module CommonMarkMathPatch
    module_function

    def install!
      patch_markdown_filter!
      patch_sanitizer!
    rescue => e
      Rails.logger.error "[redmine_katex] Extension failed: #{e.class} - #{e.message}"
    end

    def patch_markdown_filter!
      return unless defined?(Redmine::WikiFormatting::CommonMark::MarkdownFilter)

      filter_class = Redmine::WikiFormatting::CommonMark::MarkdownFilter
      unless filter_class.ancestors.include?(MarkdownFilterExtension)
        filter_class.prepend(MarkdownFilterExtension)
      end
    end

    def patch_sanitizer!
      return unless defined?(Redmine::WikiFormatting::CommonMark::SANITIZER)

      sanitizer = Redmine::WikiFormatting::CommonMark::SANITIZER
      return unless sanitizer.respond_to?(:allowlist)

      allowlist = sanitizer.allowlist
      return unless allowlist[:attributes]

      if allowlist[:attributes].frozen?
        new_allowlist = allowlist.deep_dup
        append_math_style!(new_allowlist)
        if sanitizer.respond_to?(:instance_variable_set)
          sanitizer.instance_variable_set(:@allowlist, new_allowlist)
        end
      else
        append_math_style!(allowlist)
      end
    end

    def append_math_style!(target_allowlist)
      attributes = target_allowlist[:attributes]
      span_attrs = Array(attributes['span']).dup
      unless span_attrs.include?('data-math-style')
        span_attrs << 'data-math-style'
        attributes['span'] = span_attrs
      end
    end

    module MarkdownFilterExtension
      private

      def extensions
        exts = super
        if exts.is_a?(Array)
          exts.include?(:math_dollars) ? exts : exts + [:math_dollars]
        elsif exts.is_a?(Hash)
          exts.merge(math_dollars: true)
        else
          exts
        end
      end
    end
  end
end
