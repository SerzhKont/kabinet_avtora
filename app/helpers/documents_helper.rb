module DocumentsHelper
  def status_tag_class(status)
    case status
    when "linked"
      "is-success"
    when "unlinked"
      "is-danger"
    when "pending"
      "is-info"
    when "signed"
      "is-primary"
    when "rejected"
      "is-danger"
    else
      "is-light" # По умолчанию
    end
  end
end
