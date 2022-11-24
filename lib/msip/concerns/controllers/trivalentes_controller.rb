module Msip
  module Concerns
    module Controllers
      module TrivalentesController
        extend ActiveSupport::Concern

        included do
          include ActionView::Helpers::AssetUrlHelper

          before_action :set_trivalente,
            only: [:show, :edit, :update, :destroy]
          load_and_authorize_resource class: Msip::Trivalente

          def clase
            "Msip::Trivalente"
          end

          def set_trivalente
            @basica = Msip::Trivalente.find(params[:id])
          end

          def atributos_index
            [
              :id,
              :nombre,
              :observaciones,
              :fechacreacion_localizada,
              :habilitado,
            ]
          end

          def genclase
            "M"
          end

          def trivalente_params
            params.require(:trivalente).permit(*atributos_form)
          end
        end # included
      end
    end
  end
end
