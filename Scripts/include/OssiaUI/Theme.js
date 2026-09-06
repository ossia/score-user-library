.pragma library

// Theme.js — the single source of truth for the score dark skin used by the
// Javascript preset editors (rect-mapper, presentation, advanced-text,
// tracking-zones, video-mapper...).
//
// Every colour and metric below was factored out of the tracking-zones editor,
// which is the reference for the look: dense rows, 3 px radii, one warm accent
// (#c58014, score's orange) on a near-black neutral ground.
//
// QML files in this directory read these constants directly; addons that need a
// raw value in an expression do `import OssiaUI as S` and read `S.Theme.*`.

// ---------------------------------------------------------------- surfaces
var window       = "#222222";   // outermost chrome, behind the panels
var base         = "#161514";   // panel background
var altBase      = "#1e1d1c";   // alternating list rows
var control      = "#1d1c1a";   // button / field / combo fill
var controlHover = "#2c2a27";
var controlDown  = "#3a3835";
var popup        = "#141312";   // menus and combo drop-downs
var dark         = "#0c0c0b";   // canvas / viewport void
var shadow       = "#000000";

// ------------------------------------------------------------------- lines
var border       = "#3a3835";   // control outlines
var divider      = "#252930";   // panel separators, splitter handles

// ------------------------------------------------------------------ accent
var accent       = "#c58014";   // score orange: focus, active tool, fill bars
var accentFill   = "#62400a";   // pressed / checked / highlight background
var accentText   = "#FDFDFD";

// ------------------------------------------------------------- semantic hues
var danger       = "#7a1e1e";   // destructive / locked-show tint
var dangerText   = "#ff6b6b";
var warn         = "#e0a54d";
var ok           = "#2bb3a3";
var info         = "#7ad3ff";

// -------------------------------------------------------------------- text
var text         = "#d0d0d0";   // default body text
var textStrong   = "#f0f0f0";   // headings, checked labels
var textBright   = "#f4f7f5";   // text on the accent fill
var textDim      = "#a39d96";   // secondary / indicator glyphs
var textMuted    = "#7c7670";   // disabled, placeholders, hints

// ----------------------------------------------------------------- metrics
// Tuned for density, in the spirit of Unity's inspector: short rows, small
// radii, a narrow label gutter and very little padding, so a tall panel of
// properties stays readable without scrolling for every group.
var radius       = 2;           // buttons, fields, panels
var radiusSm     = 2;           // swatches, check indicators, badges

var rowH         = 19;          // standard field height (fields, combos)
var rowHsm       = 17;          // dense rows (checks, table rows)
var toolH        = 22;          // toolbar buttons
var listRowH     = 20;          // list delegates
var tableRowH    = 16;          // monitor tables

var fontSm       = 10;          // dense panels, tables, value readouts
var fontMd       = 11;          // default control text
var fontLg       = 11;          // panel titles (bold carries the hierarchy)

var gapSm        = 1;
var gap          = 3;           // between controls in a row
var gapLg        = 5;           // between sections
var pad          = 4;           // panel inner padding
var labelW       = 88;          // inspector field-label column (all S*Row types)
var labelWsm     = 62;          // narrow variant for cramped panels

// ------------------------------------------------------------------ helpers

// "#rrggbb" + alpha -> "rgba(r,g,b,a)"; anything else is passed through.
function alpha(hex, a)
{
  var c = String(hex || "#888888");
  if (c.length === 7 && c.charAt(0) === "#") {
    var r = parseInt(c.substr(1, 2), 16);
    var g = parseInt(c.substr(3, 2), 16);
    var b = parseInt(c.substr(5, 2), 16);
    return "rgba(" + r + "," + g + "," + b + "," + a + ")";
  }
  return c;
}

// Fixed-decimal formatting that degrades to "-" instead of "NaN".
function fmt(v, d)
{
  if (v === undefined || v === null || isNaN(v))
    return "-";
  return Number(v).toFixed(d === undefined ? 2 : d);
}

// m:ss.s for durations, plain seconds below a minute.
function fmtTime(s)
{
  if (!isFinite(s))
    return "-";
  var m = Math.floor(s / 60);
  var r = s - m * 60;
  return (m ? m + ":" : "") + (m ? (r < 10 ? "0" : "") : "") + r.toFixed(1);
}

// Stable, readable colours for indexed or named series (sources, layers...).
var series = ["#7ad3ff", "#ffb86b", "#c48bff", "#8bff9d", "#ffd166", "#ff8fa3"];
function seriesColor(i)
{
  if (typeof i === "string") {
    var h = 0;
    for (var k = 0; k < i.length; k++)
      h = (h * 31 + i.charCodeAt(k)) & 0x7fffffff;
    return series[h % series.length];
  }
  return series[(i || 0) % series.length];
}

// Palette offered by the colour menus, shared so every editor picks from the
// same set.
var swatches = [
  "#2bb3a3", "#e0a54d", "#5b9bd5", "#d96b6b", "#9b7bd6", "#7fc45a",
  "#e08cc7", "#c7b24d", "#4dc0e0", "#e07d4d", "#ffffff", "#888888"
];

// "Layer 3" -> "Layer 4"; "Stage" -> "Stage 2".
function incrementName(name)
{
  var m = String(name).match(/^(.*?)(\d+)$/);
  if (m)
    return m[1] + (parseInt(m[2]) + 1);
  return name + " 2";
}
