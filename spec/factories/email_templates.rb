Factory.define :email_template do |et|
  et.sequence(:name) { |n| "Email template ##{n}" }
  et.account { Factory(:account) }
end

Factory.define :email_template_with_articles, :parent => :email_template do |et|
  et.html "<h1>Test</h1><p>{{ note }}</p><ol>{% for article in articles %}<li>{{ article.title }}</li>{% endfor %}</ol>"
  et.plaintext "Test\n====\n\n{{ note }}\n\n{% for article in articles %}-- {{ article.title }}\n{% endfor %}"
end