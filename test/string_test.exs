Code.require_file("custom_message_pack_test.exs", __DIR__)

defmodule StringTest do
  use ExUnit.Case

  test "can unpack fixed strings" do
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

  test "can unpack non fixed strings with length (2^8)-1 bytes" do
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

  test "can unpack non fixed strings with length (2^16)-1 bytes" do
    max_length = 500
    base = 256
    numbers = CustomMessagePackTest.generate_binary(max_length)

    # (500 = 00000001 11110100) -> first: 1, second: 244
    first = trunc(max_length / base)
    second = rem(max_length, base)

    message = <<0xDA, first, second>> <> numbers
    assert CustomMessagePack.unpack(message) == numbers

    # with other data in binary
    message_two = <<0xDA, first, second>> <> numbers <> <<57, 57, 57>>
    assert CustomMessagePack.unpack(message_two) == numbers
  end

  test "can unpack non fixed strings with length (2^32)-1 bytes" do
    max_length = 70_000
    base = 256
    numbers = CustomMessagePackTest.generate_binary(max_length)

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
end
