class ItemsController < InheritedResources::Base
  respond_to :json

  private
    def collection
      @items ||= Item.where(:parent_id => nil)
    end
end
