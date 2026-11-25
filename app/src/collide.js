// Convex-polygon overlap (separating axis theorem). The original used Box2D sensor
// fixtures: boxes for most sprites and a few hand-made convex hulls.

export function box(cx, cy, w, h, rotation = 0) {
  const c = Math.cos(rotation), s = Math.sin(rotation);
  return [[-w / 2, -h / 2], [w / 2, -h / 2], [w / 2, h / 2], [-w / 2, h / 2]]
    .map(([x, y]) => ({ x: cx + x * c - y * s, y: cy + x * s + y * c }));
}

// Hull points are original points relative to the sprite center with y up.
export function hull(cx, cy, points, scale) {
  return points.map(([x, y]) => ({ x: cx + x * scale, y: cy - y * scale }));
}

function project(poly, ax, ay) {
  let min = Infinity, max = -Infinity;
  for (const p of poly) {
    const d = p.x * ax + p.y * ay;
    if (d < min) min = d;
    if (d > max) max = d;
  }
  return [min, max];
}

export function overlaps(a, b) {
  for (const poly of [a, b]) {
    for (let i = 0; i < poly.length; i++) {
      const p = poly[i], q = poly[(i + 1) % poly.length];
      const ax = q.y - p.y, ay = p.x - q.x;
      const [aMin, aMax] = project(a, ax, ay);
      const [bMin, bMax] = project(b, ax, ay);
      if (aMax < bMin || bMax < aMin) return false;
    }
  }
  return true;
}
