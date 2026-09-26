require 'redmine'

require_relative 'lib/redmine_katex/hooks'
require_relative 'lib/redmine_katex/common_mark_math_patch'

Redmine::Plugin.register :redmine_katex do
  name 'Redmine KaTeX'
  author 'Redmine Community'
  description 'Fast, local math rendering using KaTeX. Zero server-side dependencies. Fully fixed.'
  version '1.0.1'
  url 'https://github.com/KaTeX/KaTeX'
  requires_redmine version_or_higher: '7.0.0'
end

Rails.application.config.to_prepare do
  RedmineKatex::CommonMarkMathPatch.install!
end
