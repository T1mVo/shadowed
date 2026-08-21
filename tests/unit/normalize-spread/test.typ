#import "../../../src/shadowed.typ": normalize-spread

// A uniform length applies to all four sides equally.
#assert.eq(
  normalize-spread(4pt, 100pt, 100pt),
  (top: 4pt, right: 4pt, bottom: 4pt, left: 4pt),
  message: "a uniform length should apply to all sides",
)

// An empty dictionary defaults every side to 0pt.
#assert.eq(
  normalize-spread((:), 100pt, 100pt),
  (top: 0pt, right: 0pt, bottom: 0pt, left: 0pt),
  message: "an empty dictionary should default to 0pt on every side",
)

// `rest` is a fallback for sides that aren't set more specifically.
#assert.eq(
  normalize-spread((rest: 2pt, top: 5pt), 100pt, 100pt),
  (top: 5pt, right: 2pt, bottom: 2pt, left: 2pt),
  message: "rest should only apply to sides without a more specific value",
)

// Explicit sides win over `rest`.
#assert.eq(
  normalize-spread(
    (rest: 1pt, top: 2pt, right: 3pt, bottom: 4pt, left: 5pt),
    100pt,
    100pt,
  ),
  (top: 2pt, right: 3pt, bottom: 4pt, left: 5pt),
  message: "top/right/bottom/left should override rest",
)

// `x` sets both the left and right side; `y` sets both the top and bottom.
#assert.eq(
  normalize-spread((x: 6pt), 100pt, 100pt),
  (top: 0pt, right: 6pt, bottom: 0pt, left: 6pt),
  message: "x should set both the left and right side",
)
#assert.eq(
  normalize-spread((y: 6pt), 100pt, 100pt),
  (top: 6pt, right: 0pt, bottom: 6pt, left: 0pt),
  message: "y should set both the top and bottom side",
)

// `x`/`y` are resolved after the individual sides, so they win when both are
// set for the same side. This mirrors the `(left: 4pt, x: 8pt)` case in the
// `spread-dict` regression test.
#assert.eq(
  normalize-spread((left: 4pt, x: 8pt), 100pt, 100pt),
  (top: 0pt, right: 8pt, bottom: 0pt, left: 8pt),
  message: "x should override an explicit left value for the same side",
)
#assert.eq(
  normalize-spread((top: 4pt, y: 8pt), 100pt, 100pt),
  (top: 8pt, right: 0pt, bottom: 8pt, left: 0pt),
  message: "y should override an explicit top value for the same side",
)

// --- Outset clamping (inset: false, the default) ---
// An outset shadow only ever grows outward, so positive spread is never
// clamped, no matter how large.
#assert.eq(
  normalize-spread((left: 1000pt, right: 1000pt), 10pt, 10pt),
  (top: 0pt, right: 1000pt, bottom: 0pt, left: 1000pt),
  message: "positive spread should never be clamped for outset shadows",
)

// Negative spread is clamped so the shadow never contracts past the box.
// Symmetric contraction on a square box halves cleanly.
#assert.eq(
  normalize-spread((left: -80pt, right: -80pt), 100pt, 100pt),
  (top: 0pt, right: -50pt, bottom: 0pt, left: -50pt),
  message: "symmetric negative spread should clamp to -width/2 on each side",
)

// Asymmetric negative spread is clamped proportionally, preserving the
// ratio between the two sides (same values as `examples/spread-clamp.typ`).
#let asym-neg-outset = normalize-spread(
  (left: -100pt, right: -50pt),
  80pt,
  80pt,
)
#assert(
  calc.abs(asym-neg-outset.left - (-53.33333pt)) < 0.001pt,
  message: "left should clamp to -80pt * 100/150",
)
#assert(
  calc.abs(asym-neg-outset.right - (-26.66667pt)) < 0.001pt,
  message: "right should clamp to -80pt * 50/150",
)

// The two axes are clamped independently: contracting past the height
// shouldn't affect a (still valid) horizontal spread.
#assert.eq(
  normalize-spread(
    (top: -40pt, bottom: -40pt, left: -1pt, right: -1pt),
    120pt,
    40pt,
  ),
  (top: -20pt, bottom: -20pt, left: -1pt, right: -1pt),
  message: "clamping one axis should not affect the other",
)

// --- Inset clamping (inset: true) ---
// An inset shadow's spread shrinks the inner hole, so it's clamped in the
// opposite direction: positive spread is clamped so the hole never inverts.
#assert.eq(
  normalize-spread((left: 30pt, right: 30pt), 40pt, 40pt, inset: true),
  (top: 0pt, right: 20pt, bottom: 0pt, left: 20pt),
  message: "symmetric spread should clamp to width/2 on each side for inset shadows",
)

// Asymmetric spread is clamped proportionally, same as the outset case.
#assert.eq(
  normalize-spread((left: 10pt, right: 40pt), 40pt, 40pt, inset: true),
  (top: 0pt, right: 32pt, bottom: 0pt, left: 8pt),
  message: "asymmetric spread should clamp proportionally for inset shadows",
)

// Negative spread only shrinks the hole further (thickening the ring), so
// it can never invert the box and is never clamped.
#assert.eq(
  normalize-spread((left: -1000pt), 10pt, 10pt, inset: true),
  (top: 0pt, right: 0pt, bottom: 0pt, left: -1000pt),
  message: "negative spread should never be clamped for inset shadows",
)

// The same spread dictionary clamps in opposite directions depending on
// `inset` — that divergence is the entire point of the parameter.
#let same-spread = (left: 30pt, right: 30pt)
#assert(
  normalize-spread(same-spread, 40pt, 40pt, inset: false)
    != normalize-spread(same-spread, 40pt, 40pt, inset: true),
  message: "outset and inset clamping should diverge for the same input",
)
