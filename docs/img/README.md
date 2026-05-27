# CADRE — Image Assets

<!-- AUDIENCE: PUBLIC. -->

## Files

| File | Format | Size | Use |
|------|--------|------|-----|
| `cadre-architecture.png` | PNG, 1920×1080 | ~260 KB | Default embed in README + docs · 1080p wallpaper · most-compatible render |
| `cadre-architecture-4k.png` | PNG, 3840×2160 | ~800 KB | 4K / high-DPI wallpaper · retina displays |
| `cadre-architecture.svg` | SVG (vector, 1920×1080 viewBox) | ~27 KB | Editable source · scales to any resolution · re-export PNG from this |

## Architecture Diagram

The diagram is the single source-of-truth picture of CADRE: the C-A-D-R-E pillars, all
10 VMs with IPs, 3 forests + trusts, telemetry stack, agentic pipeline, and the cycle.
SVG so it scales to any resolution without quality loss.

### Embedding in markdown

```markdown
![CADRE Architecture](docs/img/cadre-architecture.png)
```

PNG is the recommended embed — renders identically in every markdown viewer (GitHub,
GitLab, IDE previews, mkdocs, PDF exports). Use the SVG only if you need to edit or
re-export at a different size.

### Using as desktop wallpaper

The 1920×1080 PNG works on most monitors with no cropping. For 4K / retina, use
`cadre-architecture-4k.png` (3840×2160).

#### Windows

`Settings → Personalization → Background → Browse → cadre-architecture.png` (or
`cadre-architecture-4k.png` for high-DPI).

#### Re-rendering from SVG

If you edit `cadre-architecture.svg` and want fresh PNGs, the SVG was originally
rendered using headless Edge (built into Windows 11, no extra install):

```powershell
$svg = (Resolve-Path .\cadre-architecture.svg).Path
$url = "file:///" + ($svg -replace '\\','/')
$edge = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"

# 1080p
& $edge --headless --disable-gpu --hide-scrollbars `
        --screenshot=cadre-architecture.png --window-size=1920,1080 $url

# 4K (2× device scale factor)
& $edge --headless --disable-gpu --hide-scrollbars --force-device-scale-factor=2 `
        --screenshot=cadre-architecture-4k.png --window-size=1920,1080 $url
```

Alternative tools that work if installed: Inkscape (`inkscape --export-type=png`),
ImageMagick (`magick convert`), rsvg-convert.

### Pushing to lab VMs (optional)

After deployment, you can drop the wallpaper onto each VM so the lab itself shows the
diagram you're working against. This is purely cosmetic — not part of any test or
provisioning step.

```powershell
# From the host, copy via Vagrant SCP to each VM:
$wallpaper = (Resolve-Path .\docs\img\cadre-wallpaper.png).Path
foreach ($vm in @('dc01','dc02','dc03','mbr01','mbr02')) {
    vagrant scp $wallpaper "$vm`:C:\Users\Public\Pictures\cadre-wallpaper.png"
    vagrant winrm $vm -c "reg add 'HKCU\Control Panel\Desktop' /v Wallpaper /t REG_SZ /d 'C:\Users\Public\Pictures\cadre-wallpaper.png' /f; rundll32.exe user32.dll,UpdatePerUserSystemParameters"
}
```

For Linux VMs (linux01, monitor, elk, vr, provisioning) the wallpaper-set command
depends on the desktop environment; SSH in and use the appropriate `gsettings` /
`feh --bg-fill` / KDE / XFCE command.

### Logo-only / favicon variants

Not provided yet. If you need just the CADRE wordmark + pillar strip (for a slide deck or
favicon), open `cadre-architecture.svg` in any vector editor (Inkscape, Illustrator,
Figma) and export the top-left header group on its own.

## Diagram Source Conventions

The SVG is hand-authored, not exported from a diagram tool, so it is editable in any text
editor. Conventions:

- Canvas: 1920×1080
- Background: `#0a0e17 → #050811` linear gradient
- Pillar colors: cyan (C), purple (A), green (D), orange (R), amber (E)
- Card backgrounds: `#13191f` with `#30363d` border
- Monospace font in IP / file-path fields: `ui-monospace, 'Cascadia Code', monospace`
- Body font: Inter / Segoe UI / system-ui fallback

If you edit the SVG, please keep the layout grid (40 px units) and the pillar color
mapping consistent — these are used elsewhere in the project's visual identity.

## License

The diagram and source SVG are MIT-licensed along with the rest of the repository.
Reuse, modify, fork freely.
