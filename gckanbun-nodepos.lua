-- gckanbun-nodepos.lua
--
-- 回帰テスト専用のグリフ座標抽出ヘルパ。gckanbun.sty からは読み込まれない。
-- パッケージの挙動には一切影響しない（ノードリストを読むだけで書き換えない）。
--
-- 目的: ISSUE_BACKLOG.md #3。箱の外形 (\wd/\ht/\dp) では検出できない
-- 配置ずれを捉える。特に \makebox[0pt][r] のような幅ゼロ箱の中身は、
-- 位置がずれても外形幅に一切現れない。
--
-- 得られるのは「その箱を原点とする箱ローカル座標」であって最終ページ座標ではない。
-- 単位は sp。
--
-- 対応付けは (文字コード, その文字の何個目か) で行い、キーは "U+5929/1" の形。
-- 区切りに # を使わないのは、TeX のマクロ引数と Lua の文字列の両方で
-- エスケープを要求されて衝突するため。ノードの階層パスは
-- 診断表示にのみ使い、比較には使わない。LuaTeX-ja や jlreq の更新で
-- 入れ子構造が変わっても、見た目が同じなら差分を出さないようにするため。
-- 属性によるタグ付けは採らない。LuaTeX-ja が属性を多用しており、
-- テスト側で属性を置くと組版そのものに干渉しうるため。

local M = {}

local N = node
local GLYPH = N.id("glyph")
local HLIST = N.id("hlist")
local VLIST = N.id("vlist")
local GLUE  = N.id("glue")
local KERN  = N.id("kern")
local RULE  = N.id("rule")

-- head:   走査するノードリスト
-- parent: 直近の親箱。effective_glue が glue_set / glue_sign / glue_order を
--         参照するため必須。これを渡さないと \hbox to の伸縮が反映されない。
-- mode:   "h" = 水平に進む箱, "v" = 垂直に進む箱
local function walk(acc, head, parent, x0, y0, path, mode)
  local x, y = x0, y0
  local i = 0
  local n = head
  while n do
    local id = n.id
    i = i + 1
    if id == GLYPH then
      acc[#acc + 1] = {
        char = n.char,
        x = x + (n.xoffset or 0),
        y = y + (n.yoffset or 0),
        w = n.width, h = n.height, d = n.depth,
        path = path .. "." .. i,
      }
      if mode == "h" then x = x + n.width end
    elseif id == HLIST or id == VLIST then
      local sub = (id == HLIST) and "h" or "v"
      if mode == "h" then
        -- 水平箱の中では shift は下方向への変位
        walk(acc, n.head, n, x, y - (n.shift or 0), path .. "." .. i .. sub, sub)
        x = x + n.width
      else
        -- 垂直箱の中では shift は右方向への変位。子は自身の height ぶん下に置かれ、
        -- 次の子は height + depth だけ進んだ位置から始まる。x は進めない。
        walk(acc, n.head, n, x + (n.shift or 0), y + n.height,
             path .. "." .. i .. sub, sub)
        y = y + n.height + n.depth
      end
    elseif id == GLUE then
      local g = N.effective_glue(n, parent)
      if mode == "h" then x = x + g else y = y + g end
    elseif id == KERN then
      if mode == "h" then x = x + n.kern else y = y + n.kern end
    elseif id == RULE then
      if mode == "h" then x = x + (n.width or 0)
      else y = y + (n.height or 0) + (n.depth or 0) end
    end
    n = n.next
  end
end

-- 箱を走査して座標表を返す。
-- vertical は TeX 側から渡す。LuaTeX-ja の縦組は LuaTeX ネイティブの
-- direction ではなく箱の回転として実装されており、ノードの dir からは
-- 復元できないため、推測せずパッケージが持っている値をそのまま受け取る。
function M.scan(boxnum, vertical)
  local box = tex.getbox(boxnum)
  if not box then return nil end
  local acc = {}
  local mode = (box.id == VLIST) and "v" or "h"
  walk(acc, box.head, box, 0, 0, "0", mode)
  -- 同じ文字の何個目かを付ける
  local seen = {}
  for _, g in ipairs(acc) do
    local c = g.char
    seen[c] = (seen[c] or 0) + 1
    g.nth = seen[c]
    g.key = string.format("U+%04X/%d", c, g.nth)
  end
  return {
    box = { w = box.width, h = box.height, d = box.depth },
    vertical = vertical and true or false,
    glyphs = acc,
  }
end

-- 人が読める1行表現。golden ファイルにはこの形式で書く。
function M.format(rec)
  local out = {}
  out[#out + 1] = string.format("box w=%d h=%d d=%d vertical=%s",
    rec.box.w, rec.box.h, rec.box.d, tostring(rec.vertical))
  for _, g in ipairs(rec.glyphs) do
    out[#out + 1] = string.format("%s x=%d y=%d", g.key, g.x, g.y)
  end
  return table.concat(out, "\n")
end

-- 診断用。パスも含めて出す。
function M.format_verbose(rec)
  local out = {}
  out[#out + 1] = string.format("box w=%d h=%d d=%d vertical=%s",
    rec.box.w, rec.box.h, rec.box.d, tostring(rec.vertical))
  for _, g in ipairs(rec.glyphs) do
    out[#out + 1] = string.format("%-14s x=%-9d y=%-9d w=%-8d h=%-8d d=%-7d %s",
      g.key, g.x, g.y, g.w, g.h, g.d, g.path)
  end
  return table.concat(out, "\n")
end

return M
