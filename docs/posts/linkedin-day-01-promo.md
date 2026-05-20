# LinkedIn post — promoting Day 1 Medium piece

> Single post. ~250 words. Hook → name story → product 1-liner → one technical hook → one BA hook → CTA → tags.
> Paste into LinkedIn as-is. Replace `[Medium link]` with the real URL after publishing.

---

I'm bringing back a project name I've used before, and I want to explain why.

Two years ago I built **AEGIS** as a multi-region transaction system — an experiment in keeping money flows consistent across geographies and failure modes. Today I'm putting the name back on a different shape: an **AI credit memo / underwriting co-pilot for SME lending**. Same shield. New surface.

The thesis is simple. A credit analyst at a community bank spends about six hours on a single SME credit memo, and roughly five of those are spent on cross-document reconciliation — checking that revenue on the tax return is consistent with deposits in the bank statements, that declared owner draws match what's actually leaving the operating account, that the debt picture is internally honest. AEGIS targets eight minutes on the analyst's stopwatch, with every claim in the generated memo cited back to a specific PDF page.

**Day 1 was about the contract.** Before any LLM saw a PDF, I designed the ontology: twelve Postgres entities, with provenance columns (document, page, bounding box, model, confidence, raw blob) baked into every fact-bearing row. Most AI underwriting demos quietly skip this. It's the substrate every reliability claim later in the project will stand on.

**Why this matters from a BA-in-FinTech lens:** the differentiator isn't extraction. It's cross-document reconciliation — the work an experienced underwriter actually does. 4.5 years sitting next to credit and risk teams is what made that the load-bearing choice in v1.

Day-1 writeup is up on Medium: [Medium link]

I'll post a Day-NN entry weekly through the eight-week build. Follow along if AI × finance is your patch.

#AI #FinTech #SMELending #CreditUnderwriting #LLM #Anthropic #Claude #ForwardDeployedEngineer #BuildInPublic
