defmodule CustomMessagePack do
  # JSON standart used: RFC 7159

  import CustomGuard

  def unpack(binary) do
    %{result: result, rest: _} = unpack_value(binary)
    result
  end

  def unpack_value(binary) do
    case binary do
      # 1. nil and bool types
      <<0xC0, x::binary>> ->
        %{result: nil, rest: x}

      <<0xC2, x::binary>> ->
        %{result: false, rest: x}

      <<0xC3, x::binary>> ->
        %{result: true, rest: x}

      # 2. array types
      <<n, x::binary>> when is_fix_array(n) ->
        unpack_array(x, n - 144)

      <<0xDC, a, b, x::binary>> when is_8_bit(a) and is_8_bit(b) ->
        unpack_array(x, [a, b])

      <<0xDD, a, b, c, d, x::binary>> when are_8_bit(a, b, c, d) ->
        unpack_array(x, [a, b, c, d])

      # 3. string types
      <<n, x::binary>> when is_fixstr(n) ->
        unpack_string(x, n - 160)

      <<0xD9, n, x::binary>> when is_8_bit(n) ->
        unpack_string(x, n)

      <<0xDA, a, b, x::binary>> when is_8_bit(a) and is_8_bit(b) ->
        unpack_string(x, [a, b])

      <<0xDB, a, b, c, d, x::binary>> when are_8_bit(a, b, c, d) ->
        unpack_string(x, [a, b, c, d])

      # 4. unsigned integer types
      <<0xCC, n, x::binary>> when is_8_bit(n) ->
        %{result: n, rest: x}

      <<0xCD, a, b, x::binary>> when is_8_bit(a) and is_8_bit(b) ->
        %{result: convert_list_to_unsigned_number([a, b]), rest: x}

      <<0xCE, a, b, c, d, x::binary>> when are_8_bit(a, b, c, d) ->
        %{result: convert_list_to_unsigned_number([a, b, c, d]), rest: x}

      <<0xCF, a, b, c, d, a2, b2, c2, d2, x::binary>>
      when are_8_bit(a, b, c, d) and are_8_bit(a2, b2, c2, d2) ->
        %{result: convert_list_to_unsigned_number([a, b, c, d, a2, b2, c2, d2]), rest: x}

      # 5. signed integer types
      <<0xD0, n, x::binary>> when is_8_bit(n) ->
        %{result: n - :math.pow(2, 8), rest: x}

      <<0xD1, a, b, x::binary>> when is_8_bit(a) and is_8_bit(b) ->
        unpack_integer(x, [a, b], 16)

      <<0xD2, a, b, c, d, x::binary>> when are_8_bit(a, b, c, d) ->
        unpack_integer(x, [a, b, c, d], 32)

      <<0xD3, a, b, c, d, a2, b2, c2, d2, x::binary>>
      when are_8_bit(a, b, c, d) and are_8_bit(a2, b2, c2, d2) ->
        unpack_integer(x, [a, b, c, d, a2, b2, c2, d2], 64)
    end
  end

  defp unpack_array(bin, length_list) when is_list(length_list) do
    bin_size = convert_list_to_unsigned_number(length_list)
    unpack_array(bin, bin_size)
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
    bin_size = convert_list_to_unsigned_number(length_list)
    unpack_string(bin, bin_size)
  end

  defp unpack_string(bin, bin_size) do
    <<head::binary-size(bin_size), x::binary>> = bin
    %{result: head, rest: x}
  end

  defp unpack_integer(x, int_list, base) do
    number = convert_list_to_unsigned_number(int_list)
    %{result: number - :math.pow(2, base), rest: x}
  end

  # [1, 244] -> (00000001 11110100) -> 500
  defp convert_list_to_unsigned_number(list) do
    binary_number =
      Enum.reduce(list, "", fn i, acc ->
        acc <> (Integer.to_string(i, 2) |> String.pad_leading(8, "0"))
      end)

    {bin_size, ""} = Integer.parse(binary_number, 2)
    bin_size
  end
end
