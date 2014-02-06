class ToolsController < ApplicationController
  def create

    @tool = Tool.new(tool_params)
    @tool.save
    redirect_to root_url
  end

  private

  def tool_params
    params.require(:tool).permit([:url, :tag_list])
  end
end
