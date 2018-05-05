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

  test "can unpack signed integers" do
    # 8 bit positive
    # (1101 0000) 0000 0000
    assert CustomMessagePack.unpack(<<0xD000>>) == 0
    # (1101 0000) 0000 0011
    assert CustomMessagePack.unpack(<<0xD000>>) == 3
    # (1101 0000) 0111 1111 ->
    assert CustomMessagePack.unpack(<<0xD07F>>) == 127
    # (1101 0000) 1000 0000 ->
    assert CustomMessagePack.unpack(<<0xD080>>) == 128
    # (1101 0000) 1111 1111 ->
    assert CustomMessagePack.unpack(<<0xD0FF>>) == 255

    # 16 bit positive
    # (1100 0001) 0000 0001 0000 0000 ->
    assert CustomMessagePack.unpack(<<0xD10100>>) == 256
    # (1100 0001) 0001 0000 0101 1110 ->
    assert CustomMessagePack.unpack(<<0xD1105E>>) == 4190
    # (1100 0001) 1111 1111 1111 1111 ->
    assert CustomMessagePack.unpack(<<0xD1FFFF>>) == 65535

    # 32 bit positive
    # (1100 0010) 0000 0000 0000 0001 0000 0000 0000 0000 ->
    assert CustomMessagePack.unpack(<<0xD200010000>>) == 65536
    # (1100 0010) 1111 1111 1111 1111 1111 1111 1111 1111 ->
    assert CustomMessagePack.unpack(<<0xD2FFFFFFFF>>) == 4_294_967_295

    # 64 bit positive
    assert CustomMessagePack.unpack(<<0xD30000000100000000>>) == 4_294_967_296
    assert CustomMessagePack.unpack(<<0xD30000006968827AF4>>) == 452_724_947_700
  end
end
