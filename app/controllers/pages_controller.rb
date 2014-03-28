class PagesController < ApplicationController
  def home
    @tools = Tool.order('reproducibility_score DESC').all
    @tool = Tool.new
  end
end
