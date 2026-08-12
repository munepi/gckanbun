-- gckanbun-nodepos.lua の自己検査ロジック。
-- TeX 側のインライン \directlua を最小にするため、判定はすべてここで行う。

local NP = dofile("gckanbun-nodepos.lua")

local M = { failures = 0 }

-- spec の書式（セミコロン区切り）:
--   "U+5929/1=0,0"              絶対座標。x と y を検査
--   "U+5929/1=0"                絶対座標。x のみ検査
--   "U+5929/1->U+5730/1=589824" 2グリフの相対座標。dx のみ検査
--   "U+5929/1->U+5730/1=589824,0" 相対座標。dx と dy を検査
--
-- 縦組では LuaTeX-ja がグリフをもう1階層深い箱に包み、その包み箱が
-- 一律のオフセット（横組比で x に -0.5zw）を持つため、絶対座標は
-- 横組と縦組で比較できない。一方グリフ間の距離は両者で一致する。
-- 手計算で期待値を書けるのは相対座標の方なので、両方を扱えるようにする。
local function parse(spec)
  local abs, rel, n = {}, {}, 0
  for item in string.gmatch(spec, "[^;]+") do
    local a, b, x, y = string.match(item, "^%s*(%S+)%->(%S+)=(-?%d+),(-?%d+)%s*$")
    if not a then
      a, b, x = string.match(item, "^%s*(%S+)%->(%S+)=(-?%d+)%s*$")
    end
    if a then
      rel[#rel + 1] = { a, b, tonumber(x), y and tonumber(y) or nil }
      n = n + 1
    else
      local k
      k, x, y = string.match(item, "^%s*(%S+)=(-?%d+),(-?%d+)%s*$")
      if not k then
        k, x = string.match(item, "^%s*(%S+)=(-?%d+)%s*$")
      end
      if k then
        abs[k] = { tonumber(x), y and tonumber(y) or nil }
        n = n + 1
      else
        texio.write_nl("NP-SELFTEST BADSPEC: " .. item)
      end
    end
  end
  return abs, rel, n
end

function M.check(boxnum, name, spec, vertical)
  local rec = NP.scan(boxnum, vertical)
  local bad = {}
  local function add(s) bad[#bad + 1] = s end

  if not rec then
    add("箱が取得できない")
  else
    local abs, rel, nwant = parse(spec)
    if nwant == 0 then add("期待値を1件も解釈できなかった") end

    local bykey = {}
    for _, g in ipairs(rec.glyphs) do bykey[g.key] = g end

    for _, g in ipairs(rec.glyphs) do
      local w = abs[g.key]
      if w then
        if g.x ~= w[1] then
          add(string.format("%s x 期待%d 実測%d (差%+d)", g.key, w[1], g.x, g.x - w[1]))
        end
        if w[2] and g.y ~= w[2] then
          add(string.format("%s y 期待%d 実測%d (差%+d)", g.key, w[2], g.y, g.y - w[2]))
        end
        abs[g.key] = nil
      end
    end
    for k in pairs(abs) do add(k .. " が箱の中に見つからない") end

    for _, r in ipairs(rel) do
      local a, b = bykey[r[1]], bykey[r[2]]
      if not a then add(r[1] .. " が箱の中に見つからない")
      elseif not b then add(r[2] .. " が箱の中に見つからない")
      else
        local dx, dy = b.x - a.x, b.y - a.y
        if dx ~= r[3] then
          add(string.format("%s->%s dx 期待%d 実測%d (差%+d)", r[1], r[2], r[3], dx, dx - r[3]))
        end
        if r[4] and dy ~= r[4] then
          add(string.format("%s->%s dy 期待%d 実測%d (差%+d)", r[1], r[2], r[4], dy, dy - r[4]))
        end
      end
    end
  end

  if #bad == 0 then
    texio.write_nl("NP-SELFTEST PASS " .. name)
  else
    M.failures = M.failures + 1
    texio.write_nl("NP-SELFTEST FAIL " .. name .. ": " .. table.concat(bad, " / "))
    if rec then texio.write_nl(NP.format_verbose(rec)) end
  end
end

function M.report()
  if M.failures > 0 then
    texio.write_nl(string.format("NP-SELFTEST TOTAL %d FAILED", M.failures))
  else
    texio.write_nl("NP-SELFTEST ALL PASS")
  end
  return M.failures
end

return M
