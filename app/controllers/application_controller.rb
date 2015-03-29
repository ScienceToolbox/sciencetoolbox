class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def _render_with_renderer_json(json, options)
    serializer = build_json_serializer(json, options)

    if serializer
      super(serializer, options)
    else
      super(json, options)
    end
  end
end
