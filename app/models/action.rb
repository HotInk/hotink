# An action is an operation performed on Hot Ink data
class Action  
  def initialize(record, options = {})
    @record = record
    @options = options
  end
  
  def execute
    return false
  end
end

class PublishAction < Action
  def execute
    @record.publish!
  end
end

class ScheduleAction < Action
  include DocumentsHelper
  def execute
    @record.publish! extract_time(@options[:schedule])
  end
end

class DeleteAction < Action
  def execute
    @record.destroy
  end
end

class UnpublishAction < Action
  def execute
    @record.unpublish!
  end
end

class SetSectionAction < Action
  def execute
    category = @record.account.categories.find(@options[:category_id])
    @record.update_attribute(:section, category)
  end
end

class AddCategoryAction < Action
  def execute
    category = @record.account.categories.find(@options[:category_id])
    @record.categories << category
  end
end

class AddIssueAction < Action
  def execute
    issue = @record.account.issues.find(@options[:issue_id])
    @record.issues << issue
  end
end