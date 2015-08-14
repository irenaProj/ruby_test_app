class StaticPagesController < ApplicationController
  require 'multi_json'
  
  def home
    @content = MultiJson.load('{"abc":"def"}') #=> {"abc" => "def"}
  end

  def help
  end
end
