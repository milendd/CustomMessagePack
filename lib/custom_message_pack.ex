defmodule CustomMessagePack do
  # JSON standart used: RFC 7159

  def unpack(binary) do
    case binary do
      <<0xC0>> -> nil
      <<0xC2>> -> false
      <<0xC3>> -> true
    end
  end
end
