class PagesController < ApplicationController
  def home
    @tools = Tool.order('id DESC').order('reproducibility_score DESC').all
    @tool = Tool.new
  end
end
