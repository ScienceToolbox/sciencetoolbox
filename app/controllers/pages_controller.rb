class PagesController < ApplicationController
  def home
    @tools = Tool.all
  end
end
