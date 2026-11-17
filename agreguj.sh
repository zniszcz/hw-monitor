#!/usr/bin/env bash
# Agregacja surowych próbek (10 s, tylko lokalnie) do minut (min/śr/max), które idą do repozytorium i na stronę.
# Liczy dzisiejszy i wczorajszy dzień; surowe pliki zostają poza gitem (surowe/ w .gitignore).
export LC_ALL=C
cd "$HOME/.local/share/hw-monitor" || exit 0
for d in "$(date -d yesterday +%F)" "$(date +%F)"; do
  f="surowe/$d.csv"; [ -s "$f" ] || continue
  awk -F, 'NR>1 && $2!="" {
    m=substr($1,1,16); if(!(m in n)){ord[++k]=m; mn[m]=999}
    n[m]++; s[m]+=$2; if($2>mx[m])mx[m]=$2; if($2<mn[m])mn[m]=$2
    if($4>nv[m])nv[m]=$4; if($5>gp[m])gp[m]=$5; gu[m]+=$6; ls[m]+=$7; if($7>lm[m])lm[m]=$7; hz[m]+=$8; th[m]=$9
    if($10>w[m])w[m]=$10; b=$11/2; if(b>g[m])g[m]=b; if($12>dp[m])dp[m]=$12; if($13>ml[m])ml[m]=$13 }
  END { print "minuta,cpu_min,cpu_sr,cpu_max,nvme_max,gpu_max,gpu_proc,load_sr,load_max,mhz,dlawienie,workerzy,bramki,wdrozenie,mielarka"
    for(i=1;i<=k;i++){m=ord[i]; printf "%s,%.0f,%.1f,%.0f,%.0f,%.0f,%.0f,%.2f,%.2f,%.0f,%s,%d,%d,%d,%d\n", m,mn[m],s[m]/n[m],mx[m],nv[m],gp[m],gu[m]/n[m],ls[m]/n[m],lm[m],hz[m]/n[m],th[m],w[m],g[m],dp[m],ml[m]} }' "$f" > "minuty/$d.csv"
done
ls minuty/*.csv | sed 's|minuty/||; s|\.csv||' | awk 'BEGIN{printf "["} {printf "%s\"%s\"", (NR>1?",":""), $0} END{print "]"}' > dni.json
