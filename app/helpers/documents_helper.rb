module DocumentsHelper
  def status_tag_class(status)
    case status
    when "just_uploaded"
      "is-success"
    when "pending"
      "is-warning"
    when "signed"
      "is-primary"
    when "rejected"
      "is-danger"
    else
      "is-light" # По умолчанию
    end
  end
end
