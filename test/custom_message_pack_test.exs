defmodule CustomMessagePackTest do
  use ExUnit.Case
  doctest CustomMessagePack

  def generate_binary(n) do
    Enum.reduce(1..n, "", fn i, acc -> acc <> to_string(rem(i, 10)) end)
  end

  def generate_array(n) do
    Enum.map(1..n, fn i -> to_string(rem(i, 10)) end)
  end

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

  test "can unpack unsigned integers" do
    # 8 bit
    # (1100 1100) 0000 0000
    assert CustomMessagePack.unpack(<<0xCC, 0>>) == 0
    # (1100 1100) 0001 0001
    assert CustomMessagePack.unpack(<<0xCC, 17>>) == 17
    # (1100 1100) 0111 1111 ->
    assert CustomMessagePack.unpack(<<0xCC, 127>>) == 127
    # (1100 1100) 1000 0000 ->
    assert CustomMessagePack.unpack(<<0xCC, 128>>) == 128
    # (1100 1100) 1111 1111 ->
    assert CustomMessagePack.unpack(<<0xCC, 255>>) == 255

    # 16 bit
    # (1100 1101) 0000 0001 0000 0000 ->
    assert CustomMessagePack.unpack(<<0xCD, 1, 0>>) == 256
    # (1100 1101) 0001 0000 0101 1110 ->
    assert CustomMessagePack.unpack(<<0xCD, 16, 94>>) == 4190
    # (1100 1101) 1111 1111 1111 1111 ->
    assert CustomMessagePack.unpack(<<0xCD, 255, 255>>) == 65535

    # 32 bit
    # (1100 1110) 0000 0000 0000 0001 0000 0000 0000 0000 ->
    assert CustomMessagePack.unpack(<<0xCE, 0, 1, 0, 0>>) == 65536
    # (1100 1110) 1111 1111 1111 1111 1111 1111 1111 1111 ->
    assert CustomMessagePack.unpack(<<0xCE, 255, 255, 255, 255>>) == 4_294_967_295

    # 64 bit
    assert CustomMessagePack.unpack(<<0xCF, 0, 0, 0, 1, 0, 0, 0, 0>>) == 4_294_967_296
    assert CustomMessagePack.unpack(<<0xCF, 0, 0, 0, 105, 104, 130, 122, 244>>) == 452_724_947_700

    # with other data in binary
    assert CustomMessagePack.unpack(<<0xCC, 17, 1, 1>>) == 17
    assert CustomMessagePack.unpack(<<0xCD, 16, 94, 1, 1, 1>>) == 4190
    assert CustomMessagePack.unpack(<<0xCE, 0, 1, 0, 2, 66, 66, 66, 66>>) == 65538
    assert CustomMessagePack.unpack(<<0xCF, 0, 0, 0, 1, 0, 0, 0, 0, 55, 55, 55>>) == 4_294_967_296
  end

  test "can unpack signed integers" do
    # 8 bit
    # (1101 0000) 1111 1111
    assert CustomMessagePack.unpack(<<0xD0, 255>>) == -1
    # (1101 0000) 1110 0000
    assert CustomMessagePack.unpack(<<0xD0, 224>>) == -32
    # (1101 0000) 1101 1111 ->
    assert CustomMessagePack.unpack(<<0xD0, 223>>) == -33
    # (1101 0000) 1000 0001 ->
    assert CustomMessagePack.unpack(<<0xD0, 129>>) == -127

    # 16 bit
    # (1101 0001) 1111 1111 1000 0000 ->
    assert CustomMessagePack.unpack(<<0xD1, 255, 128>>) == -128
    # (1101 0001) 1111 1111 0111 1111 ->
    assert CustomMessagePack.unpack(<<0xD1, 255, 127>>) == -129
    # (1100 0001) 1111 1111 0000 0000 ->
    assert CustomMessagePack.unpack(<<0xD1, 255, 0>>) == -256
    # (1100 0001) 1000 0000 0000 0001 ->
    assert CustomMessagePack.unpack(<<0xD1, 128, 1>>) == -32767

    # 32 bit
    # (1100 0010) 1111 1111 1111 1111 1000 0000 0000 0000 ->
    assert CustomMessagePack.unpack(<<0xD2, 255, 255, 128, 0>>) == -32768
    # (1100 0010) 1111 1111 1111 1111 0111 1111 1111 1111 ->
    assert CustomMessagePack.unpack(<<0xD2, 255, 255, 127, 255>>) == -32769
    # (1100 0010) 1111 1111 1111 1111 0000 0000 0000 0000 ->
    assert CustomMessagePack.unpack(<<0xD2, 255, 255, 0, 0>>) == -65536
    # (1100 0010) 1000 0000 0000 0000 0000 0000 0000 0001 ->
    assert CustomMessagePack.unpack(<<0xD2, 128, 0, 0, 1>>) == -2_147_483_647

    # 64 bit
    assert CustomMessagePack.unpack(<<0xD3, 255, 255, 255, 255, 128, 0, 0, 0>>) == -2_147_483_648
    assert CustomMessagePack.unpack(<<0xD3, 255, 255, 255, 255, 0, 0, 0, 0>>) == -4_294_967_296

    # with other data in binary
    assert CustomMessagePack.unpack(<<0xD0, 224, 1, 1, 1, 1>>) == -32
    assert CustomMessagePack.unpack(<<0xD1, 255, 127, 1, 1, 1>>) == -129
    assert CustomMessagePack.unpack(<<0xD2, 255, 255, 0, 0, 77, 77, 77, 77>>) == -65536

    assert CustomMessagePack.unpack(<<0xD3, 255, 255, 255, 255, 128, 0, 0, 0, 2, 2>>) ==
             -2_147_483_648
  end

  # 
  # test "can unpack double floating point numbers" do
  #   assert CustomMessagePack.unpack(<<0xCB, 64, 19, 194, 143, 92, 40, 245, 195>>) == 4.94
  #   assert CustomMessagePack.unpack(<<0xCB, 191, 230, 102, 102, 102, 102, 102, 102>>) == -0.7
  # 
  #   # with other data in binary
  #   assert CustomMessagePack.unpack(<<0xCB, 64, 19, 194, 143, 92, 40, 245, 195, 1, 1, 1>>) == 4.94
  # 
  #   assert CustomMessagePack.unpack(<<0xCB, 191, 230, 102, 102, 102, 102, 102, 102, 1, 1, 1>>) ==
  #     -0.7
  # end
end
