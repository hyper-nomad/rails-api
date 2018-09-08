module ApplicationHelper
  def field_param_for_list model, attr, model_name = nil
    model_name ||= model.class.to_s.underscore
    identify = "#{model_name}[][#{attr}]".html_safe
  end
end
