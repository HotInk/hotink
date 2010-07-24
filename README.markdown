# Hot Ink

**Hot Ink** is a multi-account content management application built by [Canadian University Press](http://www.cup.ca) 
and [Campus Plus](http://www.campusplus.com) to help small publishers organize content for online publication. It provides 
a management interface for the upload and storage of articles, images, audiofiles, and print issue PDF files. It publishers
a public XML API (with JSON support coming soon) that's used by client applications to publish or distribute archived content.

Hot Ink is built using Ruby on Rails (v2.3.5) using Rails controllers for upload and management. Hot Ink also uses three small
Sinatra apps implemented as Rails metal:

* a single sign on server that's essentially a rework of [Hancock](http://github.com/atmos/hancock/).
* the Hot Ink API, the main public interface of the site.
* Mailout, a [Mailchimp](http://www.mailchimp.com)-API powered mass-email application that builds dynamic messages, 
filled with Hot Ink content using a simple but flexible template system. It also handles sending mass-emails to **lists** you manage using
the tools provided by your Mailchimp account.

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

## Hot Ink Publisher

[Hot Ink Publisher](http://github.com/HotInk/hotink-publisher) is a system designed to help Hot Ink users build and manage
complex websites publishing content stored in a Hot Ink archive.

## Note on Patches/Pull Requests
 
* Very much encouraged.
* Fork the project.
* Make your feature addition or bug fix.
* Add specs for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

== Copyright

Copyright (c) 2010 Canadian University Press Media Services Ltd. See LICENSE for details.