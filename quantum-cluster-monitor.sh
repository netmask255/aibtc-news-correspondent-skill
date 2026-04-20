#!/bin/bash
# Quantum Cluster Monitor — 实时监控 cluster 状态

TODAY=$(date -u +%Y-%m-%d)
SINCE="${TODAY}T00:00:00Z"

echo "=== Quantum Cluster Status ==="
echo "Date: $TODAY (UTC)"
echo

# 获取所有 approved quantum signals
curl -s "https://aibtc.news/api/signals?beat=quantum&status=approved&limit=100" | \
python3 << 'PYTHON'
import sys, json
from collections import Counter

d = json.load(sys.stdin)
signals = d.get('signals', [])

print(f"Total approved quantum signals: {len(signals)}")
print()

clusters = Counter()
cluster_signals = {}

for s in signals:
    headline = s.get('headline', '').lower()
    signal_id = s.get('id', '')[:8]
    
    # Cluster 分类
    cluster = None
    if 'bip-360' in headline or 'bip360' in headline or 'p2pkh' in headline or 'p2qrh' in headline:
        cluster = 'BIP-360/P2PKH'
    elif 'bip-361' in headline or 'bip361' in headline:
        cluster = 'BIP-361'
    elif 'nist' in headline and ('pqc' in headline or 'post-quantum' in headline):
        cluster = 'NIST/PQC'
    elif 'migration' in headline and 'quantum' in headline:
        cluster = 'Migration'
    elif 'google' in headline:
        cluster = 'Google Quantum'
    elif 'sbtc' in headline or 'peg' in headline:
        cluster = 'sBTC/Peg'
    elif 'ecdsa' in headline or 'secp256k1' in headline:
        cluster = 'ECDSA/Signature'
    elif 'lattice' in headline or 'shor' in headline or 'grover' in headline:
        cluster = 'Lattice/Shor'
    elif 'bitcoin core' in headline or 'core' in headline:
        cluster = 'Bitcoin Core'
    elif 'stacks' in headline or 'stx' in headline:
        cluster = 'Stacks/STX'
    else:
        cluster = 'Dark Domain'
    
    clusters[cluster] += 1
    if cluster not in cluster_signals:
        cluster_signals[cluster] = []
    cluster_signals[cluster].append((signal_id, s.get('headline', '')[:60]))

print("=== Cluster Distribution (4-signal cap per cluster) ===")
print()
for cluster, count in sorted(clusters.items(), key=lambda x: -x[1]):
    if count >= 4:
        status = "🔴 FULL"
        color = "\033[91m"  # Red
    elif count == 3:
        status = f"🟡 1 slot left"
        color = "\033[93m"  # Yellow
    else:
        status = f"🟢 {4-count} slots left"
        color = "\033[92m"  # Green
    
    reset = "\033[0m"
    print(f"{color}{cluster:25} {count}/4  {status}{reset}")
    
    # Show recent signals in this cluster
    for sig_id, headline in cluster_signals[cluster][:2]:
        print(f"    └─ {sig_id}: {headline}...")

print()
print("=== Opportunities (Dark Domains & Open Slots) ===")
print()
opportunities = [(cluster, count) for cluster, count in clusters.items() if count < 4]
opportunities.sort(key=lambda x: x[1])

if opportunities:
    for cluster, count in opportunities:
        slots = 4 - count
        print(f"  ✅ {cluster}: {slots} slot{'s' if slots > 1 else ''} available")
else:
    print("  ⚠️  All clusters at or near capacity")

print()
print("=== Dark Domain Signals (未分类 = 新角度) ===")
if 'Dark Domain' in cluster_signals:
    for sig_id, headline in cluster_signals['Dark Domain']:
        print(f"  • {sig_id}: {headline}...")
else:
    print("  (none)")

PYTHON

echo
echo "=== Today's Approved (UTC $TODAY) ==="
curl -s "https://aibtc.news/api/signals?beat=quantum&status=approved&since=${SINCE}&limit=100" | \
  jq -r '.signals[] | "  • \(.headline[:80])"'

echo
echo "=== Recommendation ==="
echo "1. 优先投 Dark Domain 或 slots ≥2 的 cluster"
echo "2. 避开 FULL 的 cluster（需要 displacement）"
echo "3. 检查今日 approved 避免重复角度"
