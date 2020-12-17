# frozen_string_literal: true

# Pages Controller
class PagesController < ApplicationController
  def index
    @count = session[:count].to_i
  end
end
