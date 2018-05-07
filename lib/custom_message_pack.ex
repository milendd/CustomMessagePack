defmodule CustomMessagePack do
  # JSON standart used: RFC 7159

  import CustomGuard

  def unpack(binary) do
    case binary do
      <<0xC0, _x::binary>> -> nil
      <<0xC2, _x::binary>> -> false
      <<0xC3, _x::binary>> -> true
      <<n, x::binary>> when is_fixstr(n) -> unpack_string(x, n - 160)
      <<0xD9, n, x::binary>> when is_8_bit(n) -> unpack_string(x, n)
      <<0xDA, a, b, x::binary>> when is_8_bit(a) and is_8_bit(b) -> unpack_string(x, [a, b])
      <<0xDB, a, b, c, d, x::binary>> when are_8_bit(a, b, c, d) -> unpack_string(x, [a, b, c, d])
    end
  end

  defp unpack_string(bin, x) when is_list(x) do
    binary_number =
      Enum.reduce(x, "", fn i, acc ->
        acc <> (Integer.to_string(i, 2) |> String.pad_leading(8, "0"))
      end)

    {bin_size, ""} = Integer.parse(binary_number, 2)
    unpack_string(bin, bin_size)
  end

  defp unpack_string(bin, bin_size) do
    <<head::binary-size(bin_size), _x::binary>> = bin
    head
  end
end
