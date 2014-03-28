class PagesController < ApplicationController
  def home
    @tools = Tool.order('id DESC').limit(30).all
    @tool = Tool.new
  end
end
