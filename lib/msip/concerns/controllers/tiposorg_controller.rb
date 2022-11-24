# frozen_string_literal: true

module Msip
  module Concerns
    module Controllers
      module TiposorgController
        extend ActiveSupport::Concern

        included do
          include ActionView::Helpers::AssetUrlHelper

          def clase
            "Msip::Tipoorg"
          end

          def set_tipoorg
            @basica = @tipoorg = Tipoorg.find(params[:id])
          end

          def genclase
            "M"
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

          def tipoorg_params
            params.require(:tipoorg).permit(*atributos_form)
          end
        end
      end
    end
  end
end
