# Hot Ink

**Hot Ink** is a multi-account content management application built by [Canadian University Press](http://www.cup.ca) 
and [Campus Plus](http://www.campusplus.com) to help small publishers organize content for online publication. It provides 
a management interface for the upload and storage and indexing of articles, images, audiofiles, blogs, and print issue PDF files. Hot Ink supplies a full site design management system, allowing each account's stored content to be displayed to users as a complete news-publication website.

It also publishes a public XML API (with JSON support coming soon) that can be used by client applications to publish or distribute archived content.

Hot Ink is built using Ruby on Rails (v2.3.8) using Rails controllers for upload and management. Hot Ink also uses three small
Sinatra apps implemented as Rails metal:

* a single sign on server — a modified version of [Hancock](http://github.com/atmos/hancock/).
* the Hot Ink API, a key public interface for each account.
* Mailout, a [Mailchimp](http://www.mailchimp.com)-API powered mass-email application that builds dynamic messages 
filled with Hot Ink content using a simple but flexible template system. It also handles sending mass-emails to **lists** managed using
tools provided by Mailchimp.

## Important dependencies

Search index and server are supplied by [thinking-sphinx](http://github.com/freelancing-god/thinking-sphinx/). Be sure your search
server is running properly and the necessary indexing crontab configured before attempting to upload articles or mediafiles into
the archive.

Hot Ink image processing relies on [ImageMagick](http://www.imagemagick.org/). Be sure ImageMagick is installed and in your 
application's path before attempting to upload an image.

Hot Ink PDF processing is supplied by [Ghostscript](pages.cs.wisc.edu/~ghost/). Be sure Ghostscript is also installed and in your
application's path before attempting to process an issue PDF. Actual PDF-processing is handled in the background using 
[delayed_job](http://tobi.github.com/delayed_job). Running the background jobs requires a rake task that's conveniently handled by
theses three provided scripts: `script/delayed_job start|restart|stop`. Print issue PDFs will appear to be "processing" until 
Ghostscript has built a screen-quality PDF version, which can take several minutes, depending on CPU power. Issue sizes can easily float
above 50MB per file.

## Running Hot Ink

You can set up Hot Ink for development using the following instructions.

First, clone the respository. From the command line, run:

    git clone http://github.com/HotInk/hotink.git

Be sure that both Rubygems and [Bundler](http://gembundler.com) are properly installed. In the project's directory, run:

    bundle install

By default, Hot Ink is configured to use MySQL with databases named `hotink_development` and `hotink_test`. You should adjust config/database.yml if necessary. Next, run:

	rake db:schema:load
	
Then, to start the development server:

	script/server

If the server starts successfully, when you visit /admin you should be redirected to a log in screen. 

###Creating your first account

If you see a log in screen, you're ready to set up your first Hot Ink account. Accounts are created using invitations. When an invitation is created an email is sent to the supplied address. Normally, you'll use Hot Ink's account invitation interface to handle sending invitations. However, for your first account, you'll have to set things up manually.

Access the console (using `script/console`) and create an account invitation for yourself:

	>> AccountInvitation.create(:email => "chris@hotink.net")
	=> #<AccountInvitation id: 1, email: "chris@hotink.net", redeemed: false, user_id: nil, account_id: nil, type: "AccountInvitation", token: "5ddf1eb40cec22380f28c8941ebb51813ea042be", created_at: "2010-08-01 20:27:15", updated_at: "2010-08-01 20:27:15">

Your output may not look exactly like above, but as long as the token field is set your invitation is ready to be used. In your browser,  visit your app with the path '/admin/account_invitations/YOUR_INVITATION_TOKEN/edit'. In the above example, the invitation token is `5ddf1eb40cec22380f28c8941ebb51813ea042be`. Fill out your user and account details, making note of the account name you choose.

Hot Ink identifies the current account using the account name as a subdomain. In order to use subdomains in production, you'll need to make a quick edit to your hosts file. You can likely find it in `/etc/hosts`. You should add the following line after the first entry and save the file:

    127.0.0.1   your-account-name.localhost

Don't forget to replace `your-account-name` with the name you selected when accepting your invitation. Once the hosts file is updated, you will be able to surf to http://your-account-name.localhost/admin to log in and access your first account.

But you aren't done yet. Lastly, you'll want to give yourself admin-level access to the system. To do that, access the console (using `script/console`), find your user and manually promote yourself to admin, like so:

    >> u = User.find_by_email(YOUR_EMAIL_ADDRESS) 
    >> u.promote_to_admin

Congratulations, you're now the administrator of a new installation of Hot Ink. If you're going to create or manage any documents, be sure to start the search server using the command `rake thinking_sphinx:configure && rake thinking_sphinx:start`.

## Running tests

To run the Hot Ink RSpec test suite, configure the test database in database.yml and run `rake db:test:prepare`. Next run 'spec spec', the test suite should complete successfully.

Hot Ink is Autotest friendly. To use it, run `bundle exec autospec`.

##Bugs and Issues

If you come across any bugs, issues or missing features, please [file an issue](http://github.com/HotInk/hotink/issues).

## Note on Patches/Pull Requests
 
* Very much encouraged.
* Fork the project.
* Make your feature addition or bug fix.
* Add specs for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Canadian University Press Media Services Ltd. See LICENSE for details.