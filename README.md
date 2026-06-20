# gckanbun

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Typesetting Classical Chinese in Japanese Style / 日本式漢文組版パッケージ**

---

## Overview / 概要

`gckanbun` provides a comprehensive set of commands for typesetting classical Chinese texts (Kanbun) in the traditional Japanese style.<br>
`gckanbun` は、漢文を日本式の表記法（返り点、送り仮名など）で組版するための包括的なコマンドを提供するパッケージです。

- **Version**: 2.5.3
- **Date**: 2026-06-21
- **Original Author**: Munehiro Yamamoto
- **Modified Author**: Kosei Kawaguchi (a.k.a. KKTeX)
- **Repository**: [https://github.com/munepi/gckanbun](https://github.com/munepi/gckanbun)
- **Support**: p.c.aces1056@gmail.com

---

## Key Features / 特徴

- **Flexible Command Usage / 柔軟なコマンド使用**
  - Unlike other packages, you only need to use commands for "Kaeriten" or "Okurigana" when necessary.
  - 他の類似パッケージにない強みとして、「必要な時だけ」送り仮名や返り点などのコマンドを使用すれば良いシステムになっています。

- **Advanced Return Marks / 特殊な返り点への対応**
  - Supports complex marks such as *Ichi-re-ten* (1-Return) and *Jou-re-ten* (Top-Return).
  - 一レ点、上レ点などの特殊な返り点にも対応しています。

- **Comprehensive Toolset / 漢文組版に必要な機能を網羅**
  - Covers all essential commands, including those for *Saidoku-moji* (re-read characters).
  - 再読文字を含め、漢文組版に必要なコマンドを網羅しています。
  - Supports group ruby over a base string containing return marks and other Kanbun annotations.
  - 返り点などを含む親文字列全体へのグループルビに対応しています。

- **Layout Versatility / 自由度の高いレイアウト**
  - Supports inserting Kanbun into parts of standard text, or locally inserting vertical Kanbun within a horizontal environment.
  - 通常のテキストの一部だけに漢文を入れたり、横書き環境で局所的に縦書きの漢文を入れることなどにも対応しています。
  - Supports horizontal Kanbun typesetting.
  - 横書きの漢文にも対応しています。

- **High-Quality Poetry Typesetting / 高品質な漢詩組版**
  - Provides commands for easy, high-quality typesetting of Chinese poetry.
  - 質の高い漢詩組版を簡単に行えるコマンドを提供しています。

- **Authorized Modification / 正式な改訂版**
  - Based on the original work by Munehiro Yamamoto, released as a modified version with his generous permission.
  - 山本宗宏氏によるオリジナル版に基づき、許可を得て改訂版として公開されています。

---

## Usage / 使用方法

For detailed usage and examples, please refer to the documentation file: `gckanbun-doc.pdf`.<br>
具体的な使用方法や例については、ドキュメントファイル `gckanbun-doc.pdf` を参照してください。

A compact LuaLaTeX example is available as `gckanbun-sample.tex` and `gckanbun-sample.pdf`.<br>
LuaLaTeX用の簡潔な使用例は `gckanbun-sample.tex` および `gckanbun-sample.pdf` に収録しています。

Run `make edge-test` for the horizontal LuaLaTeX corner-case matrix,
`make edge-test-tate` for the full vertical-writing matrix, and
`make edge-test-uptex` for the upLaTeX compatibility smoke test.

---

## Note / 注意点

Due to limitations of the specification, LuaLaTeX is recommended.
With (u)pLaTeX—especially (u)pLaTeX + jlreq—some features are not available.<br>
仕様上の限界により、lualatexを推奨とします。 (u)platex（特に(u)platex+jlreq）では一部の機能が使えません。

## License / ライセンス

This package is licensed under the **MIT License**.<br>
本パッケージは **MITライセンス** のもとで公開されています。

```text
Copyright (c) 2017-2026 Munehiro Yamamoto <munepixyz@gmail.com>
Copyright (c) 2025-2026 Kosei Kawaguchi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
