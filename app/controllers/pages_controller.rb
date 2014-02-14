class PagesController < ApplicationController
  def home
    @tools = Tool.order('id DESC').all
    @tool = Tool.new
  end
end
