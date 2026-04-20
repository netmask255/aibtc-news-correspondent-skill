# Quantum Beat Primary Sources

## Tier 1 (PRIMARY_DOMAINS - Gate 1 必须)

### 密码学
- https://eprint.iacr.org/ — 密码学预印本（最新研究）
- https://csrc.nist.gov/projects/post-quantum-cryptography — NIST PQC 官方
- https://www.ietf.org/ — 互联网标准

### 量子计算
- https://arxiv.org/list/quant-ph/recent — 量子物理预印本
- https://arxiv.org/list/cs.CR/recent — 密码学与安全

### Bitcoin
- https://github.com/bitcoin/bips — Bitcoin BIPs (360/361)
- https://bitcoinops.org/ — Bitcoin Optech Newsletter
- https://github.com/bitcoin/bitcoin — Bitcoin Core

### 区块链数据
- https://mempool.space/ — Bitcoin 区块链浏览器（具体 tx/address）
- https://hiro.so/ — Stacks 区块链 API

---

## Tier 2 (学术/政府 - 加分)

### 学术期刊
- https://www.nature.com/subjects/quantum-computing
- https://ieeexplore.ieee.org/
- https://journals.aps.org/

### 政府机构
- https://www.nist.gov/news-events/news — NIST 新闻
- https://www.gov.uk/government/publications — UK 政府
- https://www.go.jp/ — 日本政府

---

## Tier 3 (技术媒体 - 可用但不如 T1/T2)

- https://www.theregister.com/security/
- https://arstechnica.com/science/
- https://www.wired.com/tag/quantum-computing/
- https://www.coindesk.com/
- https://www.reuters.com/technology/
- https://www.bloomberg.com/technology

---

## 每日检查清单

### 早上 (UTC 00:00-06:00)
- [ ] eprint.iacr.org 新论文（密码学）
- [ ] arxiv.org/list/quant-ph/recent（量子计算）
- [ ] NIST PQC updates
- [ ] Bitcoin BIPs (360/361 状态)

### 下午 (UTC 12:00-18:00)
- [ ] bitcoinops.org newsletter（每周三发布）
- [ ] GitHub bitcoin/bips 新 PR
- [ ] Stacks GitHub (aibtcdev) 新 PR

### 晚上 (UTC 18:00-24:00)
- [ ] 技术媒体扫描（The Register, Ars Technica）
- [ ] 运行 quantum-cluster-monitor.sh

---

## Source 验证规则（Gate 0/1）

### Gate 0: Source Verification
- URL 必须返回 HTTP 200（不能 404）
- GitHub PR/Issue 必须 state=open
- arXiv 论文必须存在
- 具体数字必须有具体 source URL（不能只是 homepage）

### Gate 1: Verifiability
- **至少一个** PRIMARY_DOMAINS 来源
- 或者学术 TLD（.gov, .edu, .ac.uk, .ac.jp）
- Dashboard-only 不算（如 Hiro dashboard）

---

## 常见错误

❌ **错误**: 只用 Hiro API dashboard
✅ **正确**: Hiro API + arxiv.org 论文

❌ **错误**: mempool.space homepage
✅ **正确**: mempool.space/address/[specific-address]

❌ **错误**: "根据 NIST 报告"（没有具体 URL）
✅ **正确**: https://csrc.nist.gov/publications/detail/fips/203/final

---

## RSS 订阅（推荐）

```bash
# eprint.iacr.org RSS
https://eprint.iacr.org/rss/rss.xml

# arxiv.org quantum physics
https://arxiv.org/rss/quant-ph

# Bitcoin Optech
https://bitcoinops.org/feed.xml
```

