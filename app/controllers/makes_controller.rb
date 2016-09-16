class MakesController < ApplicationController
  def show
    @makes = current_make.models
  end
end
