class CommentForm < Liquid::Block
  CommentFormTagSyntax = /for\s+(#{Liquid::QuotedFragment}+)?/
  
  def initialize(tag_name, markup, tokens)      
     if markup =~ CommentFormTagSyntax
       @article_name = $1
     end

     super
   end
  
  def render(context)
    
    context['form'] = {
      'inputs' => inputs_helper,
      'submit_button' => submit_button_helper
    }        
    
    %(<form id="comment-form" method="post" action="/comments">
        <input type="hidden" name="comment[document_id]" value=#{context[@article_name].id} />
        <input type="hidden" name="authenticity_token" value="#{context.registers[:form_authenticity_token]}" />#{render_all(@nodelist, context)}</form>)
  end
  
  private
  
  def inputs_helper
    %(<fieldset class="inputs">
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
        </fieldset>)
  end
  
  def submit_button_helper
    %(<input type="submit" value="Submit" />)
  end
end