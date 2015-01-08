class ToolsController < ApplicationController
  def index
    case params[:sort]
    when "citations"
      @tools = Tool.select("tools.*, COUNT(citations.id) citations_count").
        joins("LEFT JOIN citations ON citations.tool_id = tools.id").
        group("tools.id")

      @tools = if params[:order] == "asc"
        @tools.order("citations_count ASC")
      else
        @tools.order("citations_count DESC")
      end
    else
      @tools = Tool.all
    end
  end

  def create
    @tool = Tool.new(tool_params)
    @tool.save
  end

  def show
    @tool = Tool.find(params[:id])
  end

  private

  def tool_params
    params.require(:tool).permit([:url, :tag_list])
  end
end
