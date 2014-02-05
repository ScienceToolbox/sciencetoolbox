class TagsController < ApplicationController
  def search
    if params[:q]
      @tags = ActsAsTaggableOn::Tag.where("name ILIKE ?", "%#{params[:q]}%").limit(5).all.map(&:name)
    end
    render json: @tags
  end

  def index
    @tags = ActsAsTaggableOn::Tag.all.order('name asc')
  end

  def show
    @tag = ActsAsTaggableOn::Tag.find_by_name(params[:name])
  end
end
