module DocumentsHelper
  
  #Extract time from parameter hash of appropriate strings
  def extract_time(time_hash)
    return nil if time_hash.nil?
    Time.local(time_hash[:year].to_i, time_hash[:month].to_i, time_hash[:day].to_i, time_hash[:hour].to_i, time_hash[:minute].to_i)
  end
end