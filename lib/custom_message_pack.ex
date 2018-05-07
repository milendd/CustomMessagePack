defmodule CustomMessagePack do
  # JSON standart used: RFC 7159

  import CustomGuard, only: [is_fixstr: 1]

  def unpack(binary) do
    case binary do
      <<0xC0>> -> nil
      <<0xC2>> -> false
      <<0xC3>> -> true
      <<n, x::binary>> when is_fixstr(n) -> x
    end
  end
end
