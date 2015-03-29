class PagesController < ApplicationController
  def home
    @tools = Tool.order("reproducibility_score DESC").
      page(page_params[:page]).per_page(25)
    @tool = Tool.new
  end

  private

  def page_params
    params.permit([:page])
  end
end
