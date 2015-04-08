module Api
  module V1
    class RoomsController < ApplicationController
      protect_from_forgery with: :null_session

      skip_authorization_check
      respond_to :json

      def index
        respond_with Room.all
      end

    end
  end
end
