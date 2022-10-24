require_relative '../../test_helper'

module Msip
  class TrelacionTest < ActiveSupport::TestCase

    test "valido" do
      trelacion = Trelacion.create PRUEBA_TRELACION
      assert trelacion.valid?
      trelacion.destroy!
    end

    test "no valido" do
      trelacion = Trelacion.new PRUEBA_TRELACION
      trelacion.nombre = ''
      assert_not trelacion.valid?
      trelacion.destroy!
    end

    test "existente" do
      trelacion = Msip::Trelacion.where(id: 'SI').take
      assert_equal trelacion.nombre, "SIN INFORMACIÓN"
    end

  end
end
