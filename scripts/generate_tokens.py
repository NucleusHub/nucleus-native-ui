#!/usr/bin/env python3
"""Generates the platform code for tokens/tokens.json.

Writes swift/Sources/NucleusUI/Tokens.swift. When the Android module exists it will also write its
Kotlin counterpart here, so both platforms read the same values.
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOKENS = json.loads((ROOT / "tokens/tokens.json").read_text())
SWIFT = ROOT / "swift/Sources/NucleusUI/Tokens.swift"


def color(value: str) -> str:
    """'#RRGGBB' or '#RRGGBB@0.45' as a SwiftUI Color."""
    m = re.fullmatch(r"#([0-9A-Fa-f]{6})(?:@([0-9.]+))?", value)
    if not m:
        raise SystemExit(f"bad color {value!r}")
    hex_, opacity = m.group(1).upper(), m.group(2)
    return f"Color(hex: 0x{hex_}, opacity: {opacity})" if opacity else f"Color(hex: 0x{hex_})"


def number(n) -> str:
    return repr(float(n)) if isinstance(n, float) else str(n)


def swift() -> str:
    out = ["// Generated from tokens/tokens.json by scripts/generate_tokens.py. Don't edit by hand.", "",
           "import SwiftUI", "", "/// Design tokens shared by every Nucleus app.", "public enum Nucleus {"]
    for name, c in TOKENS["colors"].items():
        if "doc" in c:
            out.append(f"    /// {c['doc']}")
        out.append(f"    public static let {name} = Color(light: {color(c['light'])}, dark: {color(c['dark'])})")
    for name, (top, bottom) in TOKENS["gradients"].items():
        out += ["",
                f"    public static let {name}Gradient = LinearGradient(",
                f"        colors: [{color(top)}, {color(bottom)}],",
                "        startPoint: .topLeading,",
                "        endPoint: .bottomTrailing",
                "    )"]
    out += ["}", "", "/// Corner radii, in points.", "public enum NucleusRadius {"]
    out += [f"    public static let {k}: CGFloat = {number(v)}" for k, v in TOKENS["radii"].items()]
    m = TOKENS["motion"]
    curve = ", ".join(number(x) for x in m["curve"])
    out += ["}", "", "public enum NucleusMotion {",
            f"    /// `--nuc-ease`: cubic-bezier({curve}).",
            f"    public static let ease = Animation.timingCurve({curve}, duration: {number(m['ease'])})",
            f"    public static let quick = Animation.timingCurve({curve}, duration: {number(m['quick'])})",
            "    /// `--nuc-step`: the delay between staggered children.",
            f"    public static let step: Double = {number(m['step'])}",
            "}", "", "public extension NucleusTint {",
            "    /// Top and bottom of the tile gradient.",
            "    var colors: (top: Color, bottom: Color) {",
            "        switch self {"]
    tints = {k: v for k, v in TOKENS["tints"].items() if not k.startswith("$")}
    out += [f"        case .{k}: ({color(top)}, {color(bottom)})" for k, (top, bottom) in tints.items()]
    out += ["        }", "    }", "}", ""]
    return "\n".join(out)


if __name__ == "__main__":
    SWIFT.write_text(swift())
    print(f"wrote {SWIFT.relative_to(ROOT)}")
