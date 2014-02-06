class PagesController < ApplicationController
  def home
    @tools = Tool.all
    @tool = Tool.new
  end
end
