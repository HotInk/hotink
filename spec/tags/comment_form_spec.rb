require 'spec_helper'

describe CommentForm do
  before do
    @article = Factory(:article)
  end

  it "should build comment form tag" do
    template = %[
      {% commentform for article %}
      {% endcommentform %}
    ]
    output = Liquid::Template.parse(template).render({ 'article' => ArticleDrop.new(@article) }, :registers => { :form_authenticity_token => "authenticity_token" })
    output.should == %[
      <form id="comment-form" method="post" action="/comments">
        <input type="hidden" name="comment[document_id]" value=#{@article.id} />
        <input type="hidden" name="authenticity_token" value="authenticity_token" />
      </form>
    ]
  end
  
  it "should include all comment form inputs, formatted formtastic-style, in a helper method" do
    template = %[
      {% commentform for article %}
        {{ form.inputs }}
      {% endcommentform %}
    ]
    output = Liquid::Template.parse(template).render({ 'article' => ArticleDrop.new(@article) }, :registers => { :form_authenticity_token => "authenticity_token" })
    output.should == %[
      <form id="comment-form" method="post" action="/comments">
        <input type="hidden" name="comment[document_id]" value=#{@article.id} />
        <input type="hidden" name="authenticity_token" value="authenticity_token" />
        <fieldset class="inputs">
          <style>#comment-form .inputs .email_confirm_input { display:none }</style>
          <ol>
            <li class="name_input">
              <label for="comment_name">Name</label>
              <input id="comment_name" maxlength="255" name="comment[name]" type="text" />
            </li>
            <li class="email_input">
              <label for="comment_email">Email</label>
              <input id="comment_email" maxlength="255" name="comment[email]" type="text" />
            </li>
            <li class="email_confirm_input">
              <label for="comment_confirm_email">Don't fill this is in</label>
              <input id="comment_confirm_email" maxlength="255" name="comment[confirm_email]" type="text" />
            </li>
            <li class="body_input">
              <label for="comment_body">Comment</label>
              <textarea id="comment_body" name="comment[body]"></textarea>
            </li>
          </ol>
        </fieldset>
      </form>
    ]
  end
  
  it "should include submit button" do
    template = %[
      {% commentform for article %}
        {{ form.submit_button }}
      {% endcommentform %}
    ]
    output = Liquid::Template.parse(template).render({ 'article' => ArticleDrop.new(@article) }, :registers => { :form_authenticity_token => "authenticity_token" })
    output.should == %[
      <form id="comment-form" method="post" action="/comments">
        <input type="hidden" name="comment[document_id]" value=#{@article.id} />
        <input type="hidden" name="authenticity_token" value="authenticity_token" />
        <input type="submit" value="Submit" />
      </form>
    ]    
  end
end
