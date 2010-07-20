require "comment_form"
require "include"

Liquid::Template.register_filter(LinkFilters)
Liquid::Template.register_filter(PaginationFilters)
Liquid::Template.register_filter(TemplateFileFilters)
Liquid::Template.register_filter(TextFilters)

Liquid::Template.register_tag('include', Include)
Liquid::Template.register_tag('commentform', CommentForm)