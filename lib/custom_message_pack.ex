defmodule CustomMessagePack do
  # JSON standart used: RFC 7159

  import CustomGuard

  def unpack(binary) do
    case binary do
      <<0xC0>> -> nil
      <<0xC2>> -> false
      <<0xC3>> -> true
      <<n, x::binary>> when is_fixstr(n) -> x
      <<0xD9, n, x::binary>> when is_8_bit(n) -> x
      <<0xDA, a, b, x::binary>> when is_8_bit(a) and is_8_bit(b) -> x
      <<0xDB, a, b, c, d, x::binary>> when are_8_bit(a, b, c, d) -> x
    end
  end
end
