defmodule CustomGuard do
  # 31 bytes for fixstr
  defguard is_fixstr(n) when is_integer(n) and n >= 160 and n <= 191

  defguard is_8_bit(n) when is_integer(n) and n >= 0 and n <= 255

  # I can't use Enum.all? because
  # ** (CompileError) invalid expression in guard, fn is not allowed in guards.
  defguard are_8_bit(a, b, c, d) when is_8_bit(a) and is_8_bit(b) and is_8_bit(c) and is_8_bit(d)
end
