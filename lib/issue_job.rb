class IssueJob < Struct.new(:issue_id)
  def perform
    Issue.find(self.issue_id).perform
  end
end