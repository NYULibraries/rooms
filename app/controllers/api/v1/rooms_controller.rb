module Api
  module V1
    class RoomsController < ApplicationController
      protect_from_forgery with: :null_session
      respond_to :json

      def index
        @rooms = Room.all
        @rooms = @rooms.limit(api_params[:rows] || 10).order("sort_order ASC")
        @rooms = @rooms.find(api_params[:id]) if api_params[:id]
        @rooms = @rooms.where(title: api_params[:title]) if api_params[:title]
        @rooms = @rooms.reorder("#{sort_field} #{sort_dir}") if api_params[:sort]

        begin
          json_rooms = @rooms.as_json(only: rooms_attributes, include: { room_group: {only: :title}}) unless api_params[:include_reservations]
          json_rooms = @rooms.as_json(only: rooms_attributes, include: { room_group: {only: :title}}, include: { current_reservations: {only: [:start_dt, :end_dt]}}) if api_params[:include_reservations]
        rescue
          json_rooms = errors.as_json
        end

        if api_params.has_key?(:pretty)
          respond_with JSON.pretty_generate(json_rooms)
        else
          respond_with json_rooms
        end
      end

    private

      def errors
        @errors ||= { error: "Invalid arguments" }
      end

      def api_params
        params.permit(:id, :pretty, :rows, :title, :sort, :sort_dir, :format, :include_reservations)
      end

      def sort_field
        api_params[:sort] if rooms_attributes.include?(api_params[:sort].to_sym)
      end

      def sort_dir
        api_params[:sort_dir] if ["asc","desc"].include?(api_params[:sort_dir].downcase)
      rescue
        "asc"
      end

      def rooms_attributes
        @rooms_attributes ||= [
          :id,
          :title,
          :description,
          :type_of_room,
          :size_of_room,
          :image_link,
          :hours,
          :sort_size_of_room,
          :sort_order,
          :opens_at,
          :closes_at
        ]
       end

    end
  end
end
