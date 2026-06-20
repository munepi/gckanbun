# KNOWN_ISSUES 対応 引き継ぎログ（codex 向け）

> このファイルは KNOWN_ISSUES.md の各項目に対する対応状況を、codex が即座に
> 続行できるよう詳細に記録したものです。CTAN 配布物には含めません
> （`Makefile` の `CTAN_FILES` に入れていないため `make zip` で除外されます）。

## メタ情報

- 作業者: Claude Code (Opus 4.8)
- 着手: 2026-06-21 01:30 JST
- 基点コミット: `93c30de`（v2.5.3, master == dev）
- 対象環境: TeX Live 2026 (LuaHBTeX 1.24.0, e-upTeX), macOS (Hiragino 利用可)
- ブランチ構成:
  - `fix/known-issues` … 自信を持って実装し**コンパイル検証済み**の確実な修正のみ（本ログもここ）
  - `experiment/whitespace-lookahead` … #1 の実装案を実際にパッチ＋計測した実験ブランチ（採否は要判断）

## 方針（ユーザー合意 2026-06-21）

1. **自信のある修正のみ Opus で実装**し、必ずコンパイルで検証する。
2. **実装に不安がある項目は、別ブランチで実装案＋テストを行い結果を記録**し、採否はメンテナに委ねる。
3. **upLaTeX 起因の不具合は対象外**。gckanbun は LuaLaTeX 前提で開発していく方針のため、
   upLaTeX 関連項目（#6, #7 と #5 の upLaTeX 部分）は「LuaLaTeX 優先方針により非ゲート」とする。

---

## ステータス一覧

| # | 区分 | 優先 | 対応 | 場所 |
|---|---|---|---|---|
| 1 | 空白感受性 | P1 | **実験完了（要採否判断）** | `experiment/whitespace-lookahead` |
| 2 | Makefile の doc 依存 | P1 | **対応済みを確認**（追加変更不要） | 既存 `Makefile:37` |
| 3 | 重なり/座標アサーション無し | P1 | 未対応（実装案を記載） | handoff |
| 4 | 不正 `intrusion` 値の黙認 | P2 | **実装・検証済み** | `fix/known-issues` `gckanbun.sty` |
| 5 | `make all` が upLaTeX 非実行 | P2 | **`make check` 追加（LuaLaTeX）・検証済み** | `fix/known-issues` `Makefile` |
| 6 | CTAN が upLaTeX edge を除外 | P2 | **既に同梱を確認**（方針により現状維持） | 既存 `Makefile:16` |
| 7 | upLaTeX 回帰の限定性 | P2 | **対象外（LuaLaTeX 優先方針）** | — |
| 8 | フォント非再現性 | P2 | 未対応（実装案を記載） | handoff |
| 9 | 可変グローバル状態 | P2(risk) | 未対応（実装案を記載） | handoff |
| 10 | 横/縦テストの重複 | P3 | 未対応（実装案を記載） | handoff |
| 11 | ドキュメントの既知警告 | P3 | **caption 警告を解消・検証済み** / b5・overfull は据え置き | `fix/known-issues` `gckanbun-doc.tex` |
| 12 | CI 不在 | P3 | 未対応（実装案を記載） | handoff |

---

## 実装・検証済み（`fix/known-issues`）

### #4 不正 `intrusion` 値の検証（実装済み）

- 変更: `gckanbun.sty` の intrusion キー定義を `.tl_set:N` から l3keys の
  `.choices:nn` へ変更。
  - `gckanbun / ruby`: `{ pre, post, both }`
  - `gckanbun / okurigana`, `gckanbun / kaeriten`: `{ post, both }`
    （コード上 `post`/`both` しか参照していないため実害なく制限）
- 効果: 不正値（例 `intrusion=typo`）で l3keys が自動的にエラーを送出。
- 検証 (2026-06-21):
  - `make check` 全アサーション PASS・FAIL ゼロ（既存の有効値の挙動不変）。
  - probe `\振り[intrusion=typo]{天}{てん}` → `lualatex` exit=1、
    エラー `Key 'gckanbun/ruby/intrusion' accepts only a fixed set of choices.`
- 備考: エラー文に許容値そのものを並べたい場合は、`.choice:` + 個別
  `intrusion / pre .code:n = …` に展開し `\msg_error` をカスタムする余地あり（任意）。

### #5 `make check`（LuaLaTeX 回帰ゲート、実装済み）

- 変更: `Makefile` に変数 `LUA_TESTS`/`LUA_TEST_PDFS` と `check` ターゲットを追加。
  `gckanbun-test` / `gckanbun-edge-test` / `gckanbun-edge-test-tate` をビルド。
  latexmk は TeX エラーで非ゼロ終了するため、`make check` 成功＝対応エンジン通過。
- upLaTeX は方針により `check` から意図的に除外（コメントで明記）。
- 検証 (2026-06-21): `make check` exit=0、edge-test のアサーション 14 件 PASS。

### #11 ドキュメント警告（caption 解消、実装済み）

- 変更: `gckanbun-doc.tex` の `\usepackage{booktabs,caption}` → `\usepackage{booktabs}`。
  doc 内に `\caption`/`captionof`/`captionsetup` の使用は無し（grep 確認済み）。
- 検証 (2026-06-21): `lualatex` exit=0。ログから caption パッケージのロード自体が
  消え（`Package: caption` 無し）、「Unknown document class」警告も消滅。
- **据え置き（要メンテナ判断）**:
  - `paper=b5` 警告（jlreq が ISO-B5 か JIS-B5 かを明示せよと警告）。
    `paper=b5j` で JIS-B5 になるが**紙面寸法が変わり tracked PDF が変化**するため、
    意図的に変更していない。JIS-B5 を採るなら `paper=b5j` に変更し PDF を再ビルド。
  - Overfull `\vbox`（約 0.71pt）: 軽微。原因ページ要素の特定後に対応。

### 付随: `.gitignore`

- `codex_doctor.json`（codex のローカル成果物）を ignore に追加（ユーザー依頼）。
- このコミットのみ `dev` に投入し、`fix/known-issues` はそこから分岐。

---

## 確認のみ（追加変更不要）

### #2 doc PDF の Makefile 依存（対応済みを確認）

- `Makefile:37` に `gckanbun-doc.pdf: gckanbun-test.pdf` が既に存在。
  汎用ルール `%.pdf: %.tex gckanbun.sty` と合わせ、KNOWN_ISSUES 推奨と同等の前提条件。
- 追加対応不要。`make distclean && make -j all` の依存検証は CI 化時（#12）に組込み推奨。

### #6 CTAN が upLaTeX edge を除外（既に同梱・方針により現状維持）

- `Makefile:16` の `CTAN_FILES` に `gckanbun-edge-test-uptex.tex`/`.pdf` が既に含まれる。
- LuaLaTeX 優先方針のもとでは、これらを「開発専用」とみなし配布から外す選択もあり得る。
  現状は同梱のままで害は無いため変更せず。方針確定後にメンテナが判断。

### #7 upLaTeX 回帰の限定性（対象外）

- **LuaLaTeX 優先方針により対象外**。upLaTeX の縦組マトリクス追加や metric アサーション
  移植は行わない。upLaTeX ファイルは非ゲートの目視スモークテストとして残置。

---

## #1 空白感受性（実験ブランチ `experiment/whitespace-lookahead`）

**結論: 実装案は有効。テストで再現の解消を確認済み。ただし「協調コマンド間の空白を
無視するか」は仕様判断のため、確実枠には入れず実験ブランチに分離。採否はメンテナへ。**

### 原因

`\futurelet` 先読み（4 箇所）が**直後のトークン 1 個**しか見ないため、コマンド間に
空白/改行が入ると後続コマンド（`\返り` 等）を検出できず、重なり補正が効かない上に
空白グルー自体が入って字間が広がる。

### 実装案（実験で適用したパッチ）

`gckanbun.sty` の 4 箇所の `\futurelet\gckanbun@let@token <handler>` を
`\peek_remove_spaces:n { … }` でラップ（全域 `\ExplSyntaxOn` 内なので空白は無視され安全）:

```
\def\gcknbn@groupruby@trail
  { \peek_remove_spaces:n { \futurelet\gckanbun@let@token\gcknbn@@groupruby@trail } }

\def\gcknbn@furigana@okurigana{% normal
  \peek_remove_spaces:n { \futurelet\gckanbun@let@token\gcknbn@@furigana@okurigana }
}

\def\gcknbn@okurigana@kaeriten{\peek_remove_spaces:n{\futurelet\gckanbun@let@token\gcknbn@@okurigana@kaeriten}}

\def\gcknbn@kaeriten@kutoten{\peek_remove_spaces:n{\futurelet\gckanbun@let@token\gcknbn@@kaeriten@kutoten}}
```

該当行（基点 `93c30de`）: `gckanbun.sty:447-448`, `478-480`, `671`, `753`。

### 計測結果 (2026-06-21, LuaLaTeX, ltjsarticle, 横組)

probe（`\setbox` 幅）:

| ケース | パッチ前 | パッチ後 |
|---|---|---|
| `\グ振り{読}{よ}\返り{レ}書`（隣接） | 23.11783pt | 23.11783pt |
| `\グ振り{読}{よ}␣\返り{レ}書`（空白） | 26.44783pt | **23.11783pt** |
| `\振り{天}{てん}\返り{レ}地`（隣接） | 23.11783pt | 23.11783pt |
| `\振り{天}{てん}␣\返り{レ}地`（空白） | 26.44783pt | **23.11783pt** |

→ 空白ありが隣接と完全一致。差 ≈3.33pt（和文1文字分の空白）が解消。

回帰: パッチ適用状態で `make check` 実行 → **FAIL ゼロ・14 PASS 維持**。既存マトリクスに回帰なし。

### 注意点（採否判断のために）

- `\peek_remove_spaces:n` は後続の**明示的空白トークンを全て**除去する。縦組の漢文では
  字間にリテラル空白を使わないため通常は望ましいが、横組で「ルビ付き文字の直後に
  意図した空白＋欧文」を置くケースでは空白が消える副作用があり得る。これが
  KNOWN_ISSUES #1 の言う「空白を無視すべきか」の設計判断。
- 改行・コメント（`%`）・グループ `{}` を挟む場合の挙動は未計測。採用時は以下を追加せよ。

### codex への次手順

1. `experiment/whitespace-lookahead` をチェックアウト（パッチ適用済み）。
2. 回帰ケースを正式追加（横・縦・各コマンド組合せ）: 空白/改行/コメント/グループ/
   `\KanHyphen` 前後/句読点前後。`experiment` ブランチ同梱の
   `gckanbun-edge-test-whitespace.tex` を雛形にできる。
3. 横組での「意図した空白＋欧文」の副作用を確認し、許容するか
   「協調コマンド直後のみ空白除去・それ以外は残す」等の限定策を検討。
4. 方針確定後、`fix/known-issues`（または `dev`）へ取り込み、doc に挙動を明記、PDF 再ビルド。

---

## 未対応（実装案のみ・codex 引き継ぎ）

### #3 重なり/座標アサーション（P1）

- 現状の edge-test は幅・高さ・深さのみ検証。グリフの実座標重なりは検出できない。
- 案A（推奨）: LuaTeX のコールバック/`\directlua` でノードリストを走査し、隣接グリフの
  水平/垂直座標と境界箱を取得してアサーション化（`luatexja` の `\inhibitglue` 周辺の
  ノード種別を参照）。`gckanbun-edge-test*.tex` の既存アサーション機構に
  「座標重なりチェック」関数を追加する形が自然。
- 案B: 安定した crop 済みフィクスチャを生成し、`pdftoppm`＋小許容差のピクセル比較。
- まず案A で「返り点が親文字に重ならない」最小ケースを 1 本作るのが着手点。

### #8 フォント再現性（P2）

- doc が macOS Hiragino を直指定（`gckanbun-doc.tex:25-34`）。他環境で代替・差異が出る。
- 案: 既定ビルドを TeX Live 同梱の原ノ味（Harano Aji）に切替（edge-test は既に
  HaranoAji を使用＝再現可能）。Hiragino は任意のドキュメント済みプロファイルとして残す。
- tracked PDF が変わるため、切替＝PDF 再ビルド＋使用 TeX Live/フォントプロファイルを記録。
- **要メンテナ判断**（配布 PDF の見た目が変わる）。実験するなら別ブランチで
  Harano Aji 版を 1 度コンパイルして体裁差を確認 → 採否。

### #9 可変グローバル状態（P2 risk）

- ルビ/送り/返りが複数のグローバル dim・bool で状態受け渡し。stale state バグの温床。
- 案（小さく安全な範囲）: 各コマンド入口で intrusion 系 tl／group-follow フラグ／
  shift dim を防御的に初期化（既に一部 `\tl_clear:N` あり。網羅して入口で reset）。
- 案（大）: 注釈状態を単一の初期化/終了プロトコル（property list 等）に集約。将来の
  メジャーバージョンで明示的合成コマンド化を検討。
- 着手点: 入口リセットの網羅化（低リスク）→ box/group/マクロ内/オプション解析失敗/
  ネスト時のテスト追加。

### #10 横/縦テストの重複（P3）

- `gckanbun-edge-test.tex` と `-tate.tex` が大半のケースを手で重複。
- 案: 共有ケース＆アサーションを小さなサポートファイル（例 `gckanbun-edge-cases.tex`）に
  括り出し、各マトリクスは documentclass と direction ラッパのみにする。
- リスク中（テスト崩れの可能性）。別ブランチで括り出し→ `make check` 一致確認後に採用。

### #12 CI（P3）

- 案: GitHub Actions に TeX Live 固定イメージ（例 `ghcr.io/.../texlive2026`）で
  `make check`（LuaLaTeX 横/縦）＋ doc ビルド＋ログスキャン＋ `make zip` を実行。
  TeX error / undefined / アサーション失敗 / 想定外 overfull で fail。
- upLaTeX は方針によりゲートに含めない（任意で非ゲートジョブ可）。
- ローカル検証不可（push 後に要確認）のため、ワークフロー追加は別 PR 推奨。雛形:

```yaml
# .github/workflows/ci.yml （草案）
name: build
on: [push, pull_request]
jobs:
  lualatex:
    runs-on: ubuntu-latest
    container: texlive/texlive:latest
    steps:
      - uses: actions/checkout@v4
      - run: make check
      - run: make doc
      - run: make zip
```

---

## 残タスク（PDF 再ビルド）

- `fix/known-issues` の確実な修正は**ソースのみコミット**し、tracked PDF は再ビルド
  していない（#4/#11 は有効出力に見た目変化が無いため、不要なバイナリ差分を避ける目的）。
- リリース手順に合わせ、メンテナ確認後に PDF を再ビルドして別コミット
  （リポジトリ慣行「Rebuild PDFs for version X」）にするのが望ましい。
