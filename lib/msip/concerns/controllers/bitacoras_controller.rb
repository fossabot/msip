# frozen_string_literal: true

module Msip
  module Concerns
    module Controllers
      module BitacorasController
        extend ActiveSupport::Concern

        included do
          include ActionView::Helpers::AssetUrlHelper

          def clase
            "Msip::Bitacora"
          end

          def atributos_index
            [
              :id,
              :fecha,
              :ip,
              :usuario_id,
              :url,
              :modelo,
              :modelo_id,
              :operacion,
              :detalle,
            ]
          end

          def atributos_form
            atributos_index - [:id] + [:params]
          end

          def index_reordenar(registros)
            registros.order(created_at: :desc)
          end

          def new_modelo_path(o)
            new_bitacora_path
          end

          def genclase
            "F"
          end

          private

          def set_bitacora
            @registro = @bitacora = Msip::Bitacora.find(params[:id].to_i)
          end

          # No confiar parametros a Internet, sólo permitir lista blanca
          def bitacora_params
            params.require(:bitacora).permit(*atributos_form)
          end
        end
      end
    end
  end
end
