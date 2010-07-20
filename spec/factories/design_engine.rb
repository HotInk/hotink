# Design engine factories

Factory.define :design do |d|
  d.account { Factory(:account) }
  d.name "Design"
end

Factory.define :template do |t|
  t.design { Factory(:design) }
  t.sequence(:code) { |n| "Template ##{n}" }
end

Factory.define :view_template do |t|
  t.design { Factory(:design) }
  t.sequence(:code) { |n| "View Template ##{n}" }
end

Factory.define :page_template do |t|
  t.design { Factory(:design) }
  t.sequence(:code) { |n| "Page Template ##{n}" }
end

Factory.define :article_template do |t|
  t.design { Factory(:design) }
  t.sequence(:code) { |n| "Article Template ##{n}" }
end

Factory.define :front_page_template do |t|
  t.design { Factory(:design) }
  t.sequence(:name) { |n| "Front Page ##{n}" }
  t.sequence(:code) { |n| "Front Page Template ##{n}" }
end

Factory.define :layout do |t|
  t.design { Factory(:design) }
  t.sequence(:name) { |n| "Layout ##{n}" }
  t.sequence(:code) { |n| "Layout ##{n} \n{{ page_contents }}" }
end

Factory.define :partial_template do |t|
  t.design { Factory(:design) }
  t.sequence(:code) { |n| "Partial Template ##{n}" }
end


Factory.define :template_file do |t|
  t.design { Factory(:design) }
  t.file { File.new(RAILS_ROOT + "/spec/fixtures/test-txt.txt")}
end

Factory.define :javascript_file do |t|
  t.design  { Factory(:design) }
  t.file  { File.new(RAILS_ROOT + '/spec/fixtures/test_js.js') }
end

Factory.define :stylesheet do |t|
  t.design  { Factory(:design) }
  t.file  { File.new(RAILS_ROOT + '/spec/fixtures/test_css.css') }
end