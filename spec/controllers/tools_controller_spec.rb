require "rails_helper"

describe ToolsController, vcr: true do
  describe "GET :id" do
    it "renders the tool JSON" do
      @tool = Tool.create(url: "http://github.com/astropy/astropy", tag_list: "astronomy")
      get :show, id: @tool.id, format: :json

      expect(response.status).to eq 200
      expect(response).to render_template("show")
      expect(assigns(:tool)).to eq(@tool)
    end
  end
end
