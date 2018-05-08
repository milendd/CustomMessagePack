defmodule CustomMessagePackTest do
  use ExUnit.Case
  doctest CustomMessagePack

  test "can unpack nil and bool types" do
    # 1100 0000
    assert CustomMessagePack.unpack(<<0xC0>>) == nil
    assert CustomMessagePack.unpack(<<0xC0, 111>>) == nil
    # 1100 0010
    assert CustomMessagePack.unpack(<<0xC2>>) == false
    assert CustomMessagePack.unpack(<<0xC2, 111>>) == false
    # 1100 0011
    assert CustomMessagePack.unpack(<<0xC3>>) == true
    assert CustomMessagePack.unpack(<<0xC3, 111>>) == true
  end

  # test "can unpack unsigned integers" do
  #   # TODO: add tests with other data
  #   # 8 bit
  #   # (1100 1100) 0000 0000
  #   assert CustomMessagePack.unpack(<<0xCC, 0>>) == 0
  #   # (1100 1100) 0001 0001
  #   assert CustomMessagePack.unpack(<<0xCC, 17>>) == 17
  #   # (1100 1100) 0111 1111 ->
  #   assert CustomMessagePack.unpack(<<0xCC, 127>>) == 127
  #   # (1100 1100) 1000 0000 ->
  #   assert CustomMessagePack.unpack(<<0xCC, 128>>) == 128
  #   # (1100 1100) 1111 1111 ->
  #   assert CustomMessagePack.unpack(<<0xCC, 255>>) == 255
  # 
  #   # 16 bit
  #   # (1100 1101) 0000 0001 0000 0000 ->
  #   assert CustomMessagePack.unpack(<<0xCD, 1, 0>>) == 256
  #   # (1100 1101) 0001 0000 0101 1110 ->
  #   assert CustomMessagePack.unpack(<<0xCD, 16, 94>>) == 4190
  #   # (1100 1101) 1111 1111 1111 1111 ->
  #   assert CustomMessagePack.unpack(<<0xCD, 255, 255>>) == 65535
  # 
  #   # 32 bit
  #   # (1100 1110) 0000 0000 0000 0001 0000 0000 0000 0000 ->
  #   assert CustomMessagePack.unpack(<<0xCE, 0, 1, 0, 0>>) == 65536
  #   # (1100 1110) 1111 1111 1111 1111 1111 1111 1111 1111 ->
  #   assert CustomMessagePack.unpack(<<0xCE, 255, 255, 255, 255>>) == 4_294_967_295
  # 
  #   # 64 bit
  #   assert CustomMessagePack.unpack(<<0xCF, 0, 0, 0, 1, 0, 0, 0, 0>>) == 4_294_967_296
  #   assert CustomMessagePack.unpack(<<0xCF, 0, 0, 0, 105, 104, 130, 122, 244>>) == 452_724_947_700
  # end
  # 
  # test "can unpack signed integers" do
  #   # TODO: add tests with other data
  #   # 8 bit
  #   # (1101 0000) 1111 1111
  #   assert CustomMessagePack.unpack(<<0xD0, 255>>) == -1
  #   # (1101 0000) 1110 0000
  #   assert CustomMessagePack.unpack(<<0xD0, 224>>) == -32
  #   # (1101 0000) 1101 1111 ->
  #   assert CustomMessagePack.unpack(<<0xD0, 223>>) == -33
  #   # (1101 0000) 1000 0001 ->
  #   assert CustomMessagePack.unpack(<<0xD0, 129>>) == -127
  # 
  #   # 16 bit
  #   # (1101 0001) 1111 1111 1000 0000 ->
  #   assert CustomMessagePack.unpack(<<0xD1, 255, 128>>) == -128
  #   # (1101 0001) 1111 1111 0111 1111 ->
  #   assert CustomMessagePack.unpack(<<0xD1, 255, 127>>) == -129
  #   # (1100 0001) 1111 1111 0000 0000 ->
  #   assert CustomMessagePack.unpack(<<0xD1, 255, 0>>) == -256
  #   # (1100 0001) 1000 0000 0000 0001 ->
  #   assert CustomMessagePack.unpack(<<0xD1, 128, 1>>) == -32767
  # 
  #   # 32 bit
  #   # (1100 0010) 1111 1111 1111 1111 1000 0000 0000 0000 ->
  #   assert CustomMessagePack.unpack(<<0xD2, 255, 255, 128, 0>>) == -32768
  #   # (1100 0010) 1111 1111 1111 1111 0111 1111 1111 1111 ->
  #   assert CustomMessagePack.unpack(<<0xD2, 255, 255, 127, 255>>) == -32769
  #   # (1100 0010) 1111 1111 1111 1111 0000 0000 0000 0000 ->
  #   assert CustomMessagePack.unpack(<<0xD2, 255, 255, 0, 0>>) == -65536
  #   # (1100 0010) 1000 0000 0000 0000 0000 0000 0000 0001 ->
  #   assert CustomMessagePack.unpack(<<0xD2, 128, 0, 0, 1>>) == -2_147_483_647
  # 
  #   # 64 bit
  #   assert CustomMessagePack.unpack(<<0xD3, 255, 255, 255, 255, 128, 0, 0, 0>>) == -2_147_483_648
  #   assert CustomMessagePack.unpack(<<0xD3, 255, 255, 255, 255, 0, 0, 0, 0>>) == -4_294_967_296
  # end
  # 
  # test "can unpack double floating point numbers" do
  #   assert CustomMessagePack.unpack(<<0xCB, 64, 19, 194, 143, 92, 40, 245, 195>>) == 4.94
  #   assert CustomMessagePack.unpack(<<0xCB, 191, 230, 102, 102, 102, 102, 102, 102>>) == -0.7
  # 
  #   # with other data in binary
  #   assert CustomMessagePack.unpack(<<0xCB, 64, 19, 194, 143, 92, 40, 245, 195, 1, 1, 1>>) == 4.94
  # 
  #   assert CustomMessagePack.unpack(<<0xCB, 191, 230, 102, 102, 102, 102, 102, 102, 1, 1, 1>>) ==
  #            -0.7
  # end

  test "can unpack fix strings" do
    assert CustomMessagePack.unpack(<<0xA0>>) == ""
    assert CustomMessagePack.unpack(<<0xA1, 48>>) == "0"
    assert CustomMessagePack.unpack(<<0xA1, 57>>) == "9"
    assert CustomMessagePack.unpack(<<0xA7, 58, 59, 60, 61, 62, 63, 64>>) == ":;<=>?@"
    assert CustomMessagePack.unpack(<<0xA1, 65>>) == "A"
    assert CustomMessagePack.unpack(<<0xA1, 90>>) == "Z"
    assert CustomMessagePack.unpack(<<0xA6, 91, 92, 93, 94, 95, 96>>) == "[\\]^_`"
    assert CustomMessagePack.unpack(<<0xA1, 97>>) == "a"
    assert CustomMessagePack.unpack(<<0xA1, 122>>) == "z"
    assert CustomMessagePack.unpack(<<0xA4, 99, 100, 101, 48>>) == "cde0"

    # with other data in binary
    assert CustomMessagePack.unpack(<<0xA1, 57, 57, 57>>) == "9"
    assert CustomMessagePack.unpack(<<0xA4, 99, 100, 101, 48, 6, 6, 6, 6, 6>>) == "cde0"
  end

  test "can unpack non fix strings with length (2^8)-1 bytes" do
    ones = to_string(1_111_111_111)
    twos = to_string(2_222_222_222)
    threes = to_string(3_333_333_333)

    numbers = <<0xD9, 32>> <> ones <> twos <> threes <> to_string(44)
    assert CustomMessagePack.unpack(numbers) == "11111111112222222222333333333344"

    numbers_two = <<0xD9, 33>> <> ones <> twos <> threes <> to_string(444)
    assert CustomMessagePack.unpack(numbers_two) == "111111111122222222223333333333444"

    # with other data in binary
    numbers_three = <<0xD9, 33>> <> ones <> twos <> threes <> to_string(444) <> <<57, 57, 57>>
    assert CustomMessagePack.unpack(numbers_three) == "111111111122222222223333333333444"
  end

  test "can unpack non fix strings with length (2^16)-1 bytes" do
    max_length = 500
    base = 256
    numbers = generate_numbers(max_length)

    # (500 = 00000001 11110100) -> first: 1, second: 244
    first = trunc(max_length / base)
    second = rem(max_length, base)

    message = <<0xDA, first, second>> <> numbers
    assert CustomMessagePack.unpack(message) == numbers

    # with other data in binary
    message_two = <<0xDA, first, second>> <> numbers <> <<57, 57, 57>>
    assert CustomMessagePack.unpack(message_two) == numbers
  end

  test "can unpack non fix strings with length (2^32)-1 bytes" do
    max_length = 70_000
    base = 256
    numbers = generate_numbers(max_length)

    # (70000 = 00000000 00000001 00010001 01110000) ->
    # first: 0, second: 1, third: 17, fourth 112
    first = trunc(max_length / (base * base * base))
    second = rem(trunc(max_length / (base * base)), base)
    third = rem(trunc(max_length / base), base)
    fourth = rem(max_length, base)

    message = <<0xDB, first, second, third, fourth>> <> numbers
    assert CustomMessagePack.unpack(message) == numbers

    # with other data in binary
    message_two = <<0xDB, first, second, third, fourth>> <> numbers <> <<57, 57, 57>>
    assert CustomMessagePack.unpack(message_two) == numbers
  end

  test "can unpack fixed arrays" do
    # TODO: add tests with numbers and objects
    assert CustomMessagePack.unpack(<<0x90>>) == []
    assert CustomMessagePack.unpack(<<0x91, 161, 97>>) == ["a"]
    assert CustomMessagePack.unpack(<<0x92, 161, 97, 161, 98>>) == ["a", "b"]
    assert CustomMessagePack.unpack(<<0x92, 161, 97, 162, 98, 99>>) == ["a", "bc"]

    assert CustomMessagePack.unpack(<<0x93, 161, 97, 162, 98, 99, 163, 100, 101, 102>>) == [
             "a",
             "bc",
             "def"
           ]

    # with other data in binary
    assert CustomMessagePack.unpack(<<0x92, 161, 97, 161, 98, 161, 98>>) == ["a", "b"]
    assert CustomMessagePack.unpack(<<0x92, 161, 97, 161, 98, 1, 1>>) == ["a", "b"]
    assert CustomMessagePack.unpack(<<0x90, 161, 97>>) == []
  end

  defp generate_numbers(n) do
    Enum.reduce(1..n, "", fn i, acc -> acc <> to_string(rem(i, 10)) end)
  end
end
