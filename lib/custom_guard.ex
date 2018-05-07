defmodule CustomGuard do
  # 31 bytes for fixstr
  defguard is_fixstr(n) when is_integer(n) and n >= 160 and n <= 191
end
