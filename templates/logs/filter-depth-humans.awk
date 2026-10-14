# How deep do REAL visitors go into a faceted filter? Pantheon nginx access log.
#
#   awk -v host=example.com -f filter-depth-humans.awk all.log            # f[] (Drupal Facets)
#   awk -v host=example.com -v key=filter -f filter-depth-humans.awk all.log
#   ... -v list=1 2>deep.txt   also writes "ip deepest requests" per human to stderr
#
# A client counts as human only if ALL hold: every filter request has a referer on
# `host`, it never probes (.txt/.php/.env/.git/wp-/user/login), it made <= 30 filter
# requests, and its filter requests are a median >= 5s apart. Referer alone is NOT
# enough: link-following crawlers send genuine referers at ~1 request per second.
# Validate against a known-human cohort before quoting (SKILL.md trap 5).
#
# Fields split on '"': $1 ip+time, $2 request, $3 status+bytes, $4 referer, $6 UA, $8 XFF.

function ts(s,   a, m) {
  split(s, a, /[\/:]/)
  m = index("JanFebMarAprMayJunJulAugSepOctNovDec", a[2])
  return (((a[3] * 400 + m) * 32 + a[1]) * 24 + a[4]) * 3600 + a[5] * 60 + a[6]
}

BEGIN {
  FS = "\""
  if (key == "") key = "f"
  # Matches key[N]= in raw or percent-encoded form, either case.
  pat = key "(%5B|%5b|\\[)[0-9]+(%5D|%5d|\\])="
}

{
  split($8, x, ", "); ip = x[1]
  if ($2 ~ /\.(txt|php|env)( |\?)|\/user\/login|wp-|\.git/) probe[ip] = 1
  split($2, r, " "); q = r[2]
  if (q !~ pat) next
  sub(/^[^?]*\?/, "", q)
  depth = gsub(pat, "", q)
  if (host == "" || index($4, host) == 0) noref[ip] = 1
  split($1, t, "["); split(t[2], tt, " ")
  n = ++cnt[ip]; when[ip, n] = ts(tt[1]); at[ip, depth]++
  if (depth > deepest[ip]) deepest[ip] = depth
}

END {
  for (ip in cnt) {
    if (noref[ip] || probe[ip] || cnt[ip] > 30) continue
    if (cnt[ip] > 1) {
      k = cnt[ip]
      for (i = 1; i <= k; i++) v[i] = when[ip, i]
      for (i = 2; i <= k; i++) for (j = i; j > 1 && v[j-1] > v[j]; j--) { s = v[j]; v[j] = v[j-1]; v[j-1] = s }
      for (i = 2; i <= k; i++) g[i-1] = v[i] - v[i-1]
      for (i = 2; i < k; i++) for (j = i; j > 1 && g[j-1] > g[j]; j--) { s = g[j]; g[j] = g[j-1]; g[j-1] = s }
      if (g[int(k / 2)] < 5) continue
    }
    humans++; reqs += cnt[ip]
    d = deepest[ip] >= 9 ? 9 : deepest[ip]; byDeepest[d]++
    for (b = 1; b <= 30; b++) byDepth[b >= 9 ? 9 : b] += at[ip, b]
    if (list) print ip, deepest[ip], cnt[ip] > "/dev/stderr"
  }
  printf "human clients: %d   filter requests: %d\n", humans, reqs
  printf "deepest per client: "; for (b = 1; b <= 9; b++) printf "%s=%d  ", (b == 9 ? "9+" : b), byDeepest[b]; print ""
  printf "requests by depth:  "; for (b = 1; b <= 9; b++) printf "%s=%d  ", (b == 9 ? "9+" : b), byDepth[b]; print ""
}
