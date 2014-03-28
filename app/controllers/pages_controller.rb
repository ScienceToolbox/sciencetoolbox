class PagesController < ApplicationController
  def home
    @tools = Tool.order('reproducibility_score DESC').limit(100).all
    @tool = Tool.new
  end
end
