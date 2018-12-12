module Webui
  module Projects
    class ProjectConfigurationController < WebuiController
      before_action :set_project
      after_action :verify_authorized, only: :update

      def show
        sliced_params = params.slice(:rev).permit!
        @content = @project.config.content(sliced_params.to_h)
        switch_to_webui2
        return if @content
        flash[:error] = @project.config.errors.full_messages.to_sentence
        redirect_to projects_path(nextstatus: 404)
      end

      def update
        authorize @project, :update?
        result = ::ProjectConfigurationService::ProjectConfigurationUpdater.new(@project, User.current, params).call
        status = if result.saved?
                   flash.now[:success] = 'Config successfully saved!'
                   200
                 else
                   flash.now[:error] = result.errors
                   400
                 end
        switch_to_webui2
        render layout: false, status: status, partial: "layouts/#{view_namespace}/flash", object: flash
      end

      private

      def view_namespace
        switch_to_webui2? ? 'webui2' : 'webui'
      end
    end
  end
end