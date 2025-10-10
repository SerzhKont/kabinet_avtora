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

  def filtered_documents_path(status = nil)
    query_params = {}

    # Безопасно обрабатываем параметры поиска
    if params[:q].is_a?(ActionController::Parameters)
      query_params[:q] = params[:q].permit!.to_h
    elsif params[:q].is_a?(Hash)
      query_params[:q] = params[:q]
    end

    # Добавляем другие параметры которые хотим сохранить
    query_params[:items] = params[:items] if params[:items].present?
    query_params[:page] = params[:page] if params[:page].present?

    # Добавляем/изменяем статус
    query_params[:status] = status

    documents_path(query_params)
  end
end
