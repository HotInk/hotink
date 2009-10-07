class Issue < ActiveRecord::Base
  belongs_to :account
  
  has_many :printings, :dependent => :destroy
  has_many :articles, :through => :printings

  has_attached_file :pdf,
      :styles => {
        :screen_quality => { :quality=>'screen', :processors => [:pdf_quality_filter]},
        #:system_cover_icon => [ "x20>", 'jpg' ],
        :system_cover_thumb => ["175>", 'jpg'],
        #:thumb_cover  => Proc.new { |instance| instance.settings["thumb"].to_s },
        #:small_cover => Proc.new { |instance| instance.settings["small"].to_s },
       # :medium_cover => Proc.new { |instance| instance.settings["medium"].to_s },
        :system_default => ["400>", 'jpg']
      #  :large_cover => Proc.new { |instance| instance.settings["large"].to_s }
      },
      :convert_options => {
        :all => "-colorspace RGB"
      },
      :default_url => '/images/no_issue_cover_small.jpg',
      :default_style => :system_cover_thumb,
      :path => ":rails_root/public/system/:account/:class/:id_partition/:basename_:style.:extension",
      :url => "/system/:account/:class/:id_partition/:basename_:style.:extension"
  
  
  validates_presence_of :account, :message => "must be attached"
  validates_associated :account, :message => "must be valid"
  validates_date :date, :format => "yyyy-mm-dd", :invalid_date_message => "must be formattted 'YYYY-MM-DD' style"
  
  # Default settings
  # Right now these image sizes are processed automatically.
  def settings
       default_settings = {
        "thumb" => ['50>', 'jpg'],
        "small" => ['148>', 'jpg'],
        "medium" => ['500>', 'jpg'],
        "large" => ['800>', 'jpg']
        }
    if self.account
      default_settings.merge!(self.account.settings["issue"]) if self.account.settings["issue"] if self.account.settings
      return default_settings
    else
      return default_settings 
    end
  end
  
  # Callbacks
  before_pdf_post_process do |issue|
    issue.processing = true if issue.pdf.dirty? # If the PDF has changed, mark the issue for processing
    
    false if issue.processing? # do not process if just added, processing attribute defaults to 'true'
  end
  
  after_update do |issue|
    Delayed::Job.enqueue IssueJob.new(issue.id) if issue.processing? # add to queue if the PDF is new
  end
  
  # DelayedJob for PDF processing
  def perform
    self.processing = false # unlock for processing
    pdf.reprocess! # do the processing
    save
  end
  
  # Fix the mime types on uploaded PDFs. Make sure to require the mime-types gem
  def swfupload_file=(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s
    self.pdf = data
  end
  
  def pdf_url(style = :original)
    if self.pdf && processing? && style != :original
      return pdf.send(:interpolate, '/images/processing_issue.jpg', "#{style}")
    end
    pdf.url(style)
  end
  
  def to_xml(options = {})
      options[:indent] ||= 2
      xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
      xml.instruct! unless options[:skip_instruct]
      
      xml.issue do 
        xml.tag!( :id, self.id )
        xml.tag!( :account_id, self.account.id )
        xml.tag!( :account_name, self.account.formal_name.blank? ? self.account.name.capitalize : self.account.formal_name )

        xml.tag!( :date, self.date )
        xml.tag!( :name, self.name )
        xml.tag!( :description, self.description )
        xml.tag!( :volume, self.volume )
        xml.tag!( :number, self.number )

        xml.tag!( :press_pdf_file, self.pdf.url(:original) )
        if self.pdf.path(:screen_quality) && File.exists?(self.pdf.path(:screen_quality))
          xml.tag!( :screen_pdf_file, self.pdf.url(:screen_quality) )
        else
          xml.tag!( :screen_pdf_file, self.pdf.url(:original) )
        end
        xml.tag!( :large_cover_image, self.pdf.url(:system_default) )
        xml.tag!( :small_cover_image, self.pdf.url(:system_cover_thumb) )

        xml.tag!(:created_at, self.created_at.to_formatted_s(:long))
        xml.tag!(:last_updated, self.updated_at.to_formatted_s(:long))
      end
  end
  
end
