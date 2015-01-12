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

  describe "GET :index" do
    before do
      @tool = Tool.create(url: "http://github.com/astropy/astropy", tag_list: "astronomy")
      @tool2 = Tool.create(url: "https://github.com/meren/illumina-utils", tag_list: "illumina")
      @citation = Citation.create(doi: "test", tool: @tool2)
    end

    it "renders the index template" do
      get :index, format: :json

      expect(response.status).to eq 200
      expect(response).to render_template("index")
      expect(assigns(:tools)).to eq([@tool, @tool2])
    end

    it "sorts by citations" do
      get :index, sort: "citations", format: :json

      expect(response.status).to eq 200
      expect(response).to render_template("index")

      expect(assigns(:tools)).to eq([@tool2, @tool])
    end
  end

  describe "GET :search", vcr: true do
    before :each do
      @tool = Tool.create!(url: "http://github.com/astropy/astropy", tag_list: "astronomy,foobar")
      Tool.import
      Tool.__elasticsearch__.refresh_index!
    end

    it "finds the result" do
      get :search, query: "astropy", format: :json

      expect(response.status).to eq 200
      expect(assigns(:tools)).to eq([@tool])
    end

    it "finds the result by its tag" do
      get :search, query: "foobar", format: :json

      expect(response.status).to eq 200
      expect(assigns(:tools)).to eq([@tool])
    end

    it "doesn't find results for nonexistant terms" do
      get :search, query: "arrrrr", format: :json

      expect(response.status).to eq 200
      expect(assigns(:tools)).to eq([])
    end
  end
end
