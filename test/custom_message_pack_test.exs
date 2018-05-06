defmodule CustomMessagePackTest do
  use ExUnit.Case
  doctest CustomMessagePack

  test "can unpack nil and bool types" do
    # 1100 0000
    assert CustomMessagePack.unpack(<<0xC0>>) == nil
    # 1100 0010
    assert CustomMessagePack.unpack(<<0xC2>>) == false
    # 1100 0011
    assert CustomMessagePack.unpack(<<0xC3>>) == true
  end

  test "can unpack unsigned integers" do
    # 8 bit
    # (1100 1100) 0000 0000
    assert CustomMessagePack.unpack(<<0xCC00>>) == 0
    # (1100 1100) 0001 0001
    assert CustomMessagePack.unpack(<<0xCC11>>) == 17
    # (1100 1100) 0111 1111 ->
    assert CustomMessagePack.unpack(<<0xCC7F>>) == 127
    # (1100 1100) 1000 0000 ->
    assert CustomMessagePack.unpack(<<0xCC80>>) == 128
    # (1100 1100) 1111 1111 ->
    assert CustomMessagePack.unpack(<<0xCCFF>>) == 255

    # 16 bit
    # (1100 1101) 0000 0001 0000 0000 ->
    assert CustomMessagePack.unpack(<<0xCD0100>>) == 256
    # (1100 1101) 0001 0000 0101 1110 ->
    assert CustomMessagePack.unpack(<<0xCD105E>>) == 4190
    # (1100 1101) 1111 1111 1111 1111 ->
    assert CustomMessagePack.unpack(<<0xCDFFFF>>) == 65535

    # 32 bit
    # (1100 1110) 0000 0000 0000 0001 0000 0000 0000 0000 ->
    assert CustomMessagePack.unpack(<<0xCE00010000>>) == 65536
    # (1100 1110) 1111 1111 1111 1111 1111 1111 1111 1111 ->
    assert CustomMessagePack.unpack(<<0xCEFFFFFFFF>>) == 4_294_967_295

    # 64 bit
    assert CustomMessagePack.unpack(<<0xCF0000000100000000>>) == 4_294_967_296
    assert CustomMessagePack.unpack(<<0xCF0000006968827AF4>>) == 452_724_947_700
  end

  test "can unpack signed integers" do
    # 8 bit
    # (1101 0000) 1111 1111
    assert CustomMessagePack.unpack(<<0xD0FF>>) == -1
    # (1101 0000) 1110 0000
    assert CustomMessagePack.unpack(<<0xD0E0>>) == -32
    # (1101 0000) 1101 1111 ->
    assert CustomMessagePack.unpack(<<0xD0DF>>) == -33
    # (1101 0000) 1000 0001 ->
    assert CustomMessagePack.unpack(<<0xD081>>) == -127

    # 16 bit
    # (1101 0001) 1111 1111 1000 0000 ->
    assert CustomMessagePack.unpack(<<0xD1FF80>>) == -128
    # (1101 0001) 1111 1111 0111 1111 ->
    assert CustomMessagePack.unpack(<<0xD1FF7F>>) == -129
    # (1100 0001) 1111 1111 0000 0000 ->
    assert CustomMessagePack.unpack(<<0xD1FF00>>) == -256
    # (1100 0001) 1000 0000 0000 0001 ->
    assert CustomMessagePack.unpack(<<0xD18001>>) == -32767

    # 32 bit
    # (1100 0010) 1111 1111 1111 1111 1000 0000 0000 0000 ->
    assert CustomMessagePack.unpack(<<0xD2FFFF8000>>) == -32768
    # (1100 0010) 1111 1111 1111 1111 0111 1111 1111 1111 ->
    assert CustomMessagePack.unpack(<<0xD2FFFF7FFF>>) == -32769
    # (1100 0010) 1111 1111 1111 1111 0000 0000 0000 0000 ->
    assert CustomMessagePack.unpack(<<0xD2FFFF0000>>) == -65536
    # (1100 0010) 1000 0000 0000 0000 0000 0000 0000 0001 ->
    assert CustomMessagePack.unpack(<<0xD280000001>>) == -2_147_483_647

    # 64 bit
    assert CustomMessagePack.unpack(<<0xD3FFFFFFFF80000000>>) == -2_147_483_648
    assert CustomMessagePack.unpack(<<0xD3FFFFFFFF00000000>>) == -4_294_967_296
  end

  test "can unpack double floating point numbers" do
    assert CustomMessagePack.unpack(<<0xCB4013C28F5C28F5C3>>) == 4.94
    assert CustomMessagePack.unpack(<<0xCBBFE6666666666666>>) == -0.7
  end

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
  end
end
