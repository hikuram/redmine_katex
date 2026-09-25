# frozen_string_literal: true

module RedmineKatex
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context = {})
      tags = []
      tags << stylesheet_link_tag("katex/katex.min.css", media: :all, plugin: 'redmine_katex')
      tags << javascript_include_tag("katex/katex.min.js", defer: true, plugin: 'redmine_katex')
      tags << javascript_include_tag("katex/auto-render.min.js", defer: true, plugin: 'redmine_katex')
      tags << javascript_include_tag("katex/mhchem.min.js", defer: true, plugin: 'redmine_katex')
      tags << javascript_include_tag("redmine_katex_init.js", defer: true, plugin: 'redmine_katex')
      tags.join("\n").html_safe
    end
  end
end
