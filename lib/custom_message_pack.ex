defmodule CustomMessagePack do
  # JSON standart used: RFC 7159

  import CustomGuard

  def unpack(binary) do
    %{result: result, rest: _} = unpack_value(binary)
    result
  end

  def unpack_value(binary) do
    case binary do
      <<0xC0, x::binary>> -> %{result: nil, rest: x}
      <<0xC2, x::binary>> -> %{result: false, rest: x}
      <<0xC3, x::binary>> -> %{result: true, rest: x}
      <<n, x::binary>> when is_fix_array(n) -> unpack_array(x, n - 144)
      <<n, x::binary>> when is_fixstr(n) -> unpack_string(x, n - 160)
      <<0xD9, n, x::binary>> when is_8_bit(n) -> unpack_string(x, n)
      <<0xDA, a, b, x::binary>> when is_8_bit(a) and is_8_bit(b) -> unpack_string(x, [a, b])
      <<0xDB, a, b, c, d, x::binary>> when are_8_bit(a, b, c, d) -> unpack_string(x, [a, b, c, d])
    end
  end

  defp unpack_array(<<>>, _), do: %{result: [], rest: <<>>}

  defp unpack_array(x, 0) when is_bitstring(x) do
    %{result: [], rest: x}
  end

  defp unpack_array(x, n) when is_bitstring(x) do
    %{result: result, rest: rest} = unpack_value(x)
    %{result: new_result, rest: rest} = unpack_array(rest, n - 1)
    %{result: [result | new_result], rest: rest}
  end

  defp unpack_string(bin, length_list) when is_list(length_list) do
    binary_number =
      Enum.reduce(length_list, "", fn i, acc ->
        acc <> (Integer.to_string(i, 2) |> String.pad_leading(8, "0"))
      end)

    {bin_size, ""} = Integer.parse(binary_number, 2)
    unpack_string(bin, bin_size)
  end

  defp unpack_string(bin, bin_size) do
    <<head::binary-size(bin_size), x::binary>> = bin
    %{result: head, rest: x}
  end
end
