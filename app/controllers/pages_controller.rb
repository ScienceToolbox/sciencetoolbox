class PagesController < ApplicationController
  def home
    @tools = Tool.order('reproducibility_score DESC')
                 .page(params[:page]).per_page(25)
    @tool = Tool.new
  end
end
