---
layout: single
title: "The Clo-Author: Your Econ AI Research Assistant for Claude Code"
permalink: /clo-author/
sidebar:
  nav: "clo-author"
classes: wide
use_math: true
---

<div style="text-align: center; margin: 0.5em 0 1em;">
  <img src="/assets/images/clo-author-demo.gif" alt="Clo-Author in action" style="max-width: 100%; border-radius: 8px; border: 2px solid #2a9d8f; box-shadow: 0 2px 8px rgba(0,0,0,0.12);">
  <p style="font-size: 0.7em; color: #aaa; margin-top: 0.3em; font-style: italic;">Clodovil, legendary presenter</p>
</div>

An open-source [Claude Code](https://docs.anthropic.com/en/docs/claude-code) workflow that turns your terminal into a full-service applied econometrics research assistant — from literature review to journal submission.

**Built on** [Pedro Sant'Anna's claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow) template, reoriented for **applied econometrics research publication**.

> **A note on responsibility.** AI is a powerful research accelerator, but it is not a substitute for scholarly judgment. You remain the principal investigator — the one who owns every identification assumption, every coefficient interpretation, and every claim in the manuscript. The Clo-Author is designed to make you a better supervisor of your own work: it checks your code, stress-tests your design, and catches errors before referees do. But no automated review can replace your understanding of the institutional context behind your data or the economic intuition that motivates your model. Use these tools honestly — disclose AI assistance where journals require it, verify every output, and never let convenience erode rigor. The goal is not to produce papers faster; it is to produce *better* papers, with fewer errors and stronger identification, while you focus on the ideas that only a human researcher can provide.

[Fork it on GitHub](https://github.com/hsantanna88/clo-author){: .btn .btn--primary .btn--large}

---

## Quick Start

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (Anthropic's CLI tool)
- XeLaTeX (via TeX Live or MacTeX)
- R (with [`fixest`](https://cran.r-project.org/package=fixest), [`did`](https://cran.r-project.org/package=did), [`modelsummary`](https://cran.r-project.org/package=modelsummary), [`ggplot2`](https://cran.r-project.org/package=ggplot2))
- `gh` CLI (for GitHub integration)

### Setup

```bash
# 1. Fork and clone
gh repo fork hsantanna88/clo-author --clone
cd clo-author

# 2. Open Claude Code
claude
```

Then give Claude this prompt:

> I'm starting a new applied econometrics research project on [YOUR TOPIC].
> Read CLAUDE.md and the workflow quick reference.
> Help me set up the project structure and start with a literature review.

That is all you need. Claude reads the workflow configuration and becomes your research assistant.

---

## How It Works

### Contractor Mode

You give instructions in plain language. The Clo-Author:

1. **Plans** the approach (for non-trivial tasks)
2. **Implements** — writes LaTeX, R code, generates tables
3. **Reviews** — runs specialized agents (econometrician, proofreader, R-reviewer)
4. **Fixes** issues found by reviewers
5. **Re-verifies** — confirms fixes compile cleanly
6. **Scores** against quality gates (80/90/95)
7. **Reports** back with a summary

This is the **orchestrator loop** — it runs autonomously after you approve the plan. Max 5 review-fix rounds to prevent infinite loops.

### Plan-First Workflow

Before any non-trivial task, Claude enters **plan mode**:

1. Explores the codebase and relevant files
2. Drafts a plan (what changes, which files, in what order)
3. Saves the plan to `quality_reports/plans/`
4. Presents it for your approval
5. Only then begins implementation

For complex or ambiguous tasks, Claude will first create a **requirements specification** using MUST/SHOULD/MAY framework, then plan against it. This reduces mid-task pivots significantly.

### Quality Gates

| Score | Paper & R Scripts | Talks |
|-------|------------------|-------|
| **95+** | Excellence — ready for top-5 | Advisory only |
| **90+** | Submit — ready for journal | (reported, non-blocking) |
| **80+** | Commit — good enough to save | |
| **< 80** | **Blocked** — fix issues first | |

Paper scores are **blocking** — nothing ships below 80. Talk scores are **advisory** — reported but do not prevent commits.

---

## The Production Pipeline

The following diagram shows how the full orchestrator loop works, from your request to the final output:

![The Clo-Author Production Pipeline](/assets/images/clo-author-pipeline.svg)

The key insight: **review agents run in parallel**, then issues are fixed in priority order (critical first), and the loop repeats until the quality gate is met.

---

## The Agents

The Clo-Author ships with **12 specialized agents** (8 core agents described below; plus 4 from the lecture-production lineage: Beamer Translator, Quarto Critic, Quarto Fixer, and Pedagogy Reviewer). Each is a read-only reviewer with deep domain expertise. Agents do not edit files — they produce reports. The orchestrator (or you) decides what to fix.

![Agent Relationships](/assets/images/clo-author-agents.svg)

### Econometrician — The Centerpiece

The econometrician agent is a top-journal referee that validates your causal inference through **6 lenses**:

| Lens | What It Checks |
|------|---------------|
| **Identification Design** | DiD (classic + staggered [CS](https://doi.org/10.1016/j.jeconom.2020.12.001)/[SA](https://doi.org/10.1016/j.jeconom.2020.09.006)/[BJS](https://doi.org/10.3982/ECTA17813)), IV with weak instrument diagnostics, RDD with [rdrobust](https://cran.r-project.org/package=rdrobust)/[McCrary](https://doi.org/10.1016/j.jeconom.2007.11.004), Synthetic Control with permutation inference, Event Studies with lead-lag specification |
| **Assumption Stress Test** | Internal/external validity threats, spillovers, selection on unobservables, SUTVA violations, common support |
| **SE & Inference** | Clustering level justification, wild cluster bootstrap (few clusters), [Conley](https://doi.org/10.1016/S0304-4076(98)00084-0) spatial HAC, [Romano-Wolf](https://doi.org/10.1080/01621459.2016.1226710) multiple testing corrections |
| **Robustness Protocol** | [Oster](https://doi.org/10.1080/07350015.2016.1227711) bounds for selection on unobservables, placebo/falsification tests, specification curves, leave-one-out sensitivity |
| **Code-Theory Alignment** | [`fixest`](https://cran.r-project.org/package=fixest) clustering syntax, [`did`](https://cran.r-project.org/package=did)/[`fastdid`](https://cran.r-project.org/package=fastdid) package API usage, [`rdrobust`](https://cran.r-project.org/package=rdrobust) bandwidth selection, correct estimand specification |
| **Citation Fidelity** | Correct attribution for [Callaway-Sant'Anna](https://doi.org/10.1016/j.jeconom.2020.12.001), [Sun-Abraham](https://doi.org/10.1016/j.jeconom.2020.09.006), [Borusyak-Jaravel-Spiess](https://doi.org/10.3982/ECTA17813), [Oster](https://doi.org/10.1080/07350015.2016.1227711), [rdrobust](https://rdpackages.github.io/rdrobust/) methodology papers |
{: .agent-table}

**Package-flexible:** The econometrician recommends best practices ([Callaway-Sant'Anna](https://doi.org/10.1016/j.jeconom.2020.12.001) for staggered DiD, [`fixest`](https://cran.r-project.org/package=fixest) for panels, [`rdrobust`](https://cran.r-project.org/package=rdrobust) for RDD) but **accepts and validates** alternative packages without flagging them as errors:

- **DiD:** [`did`](https://cran.r-project.org/package=did), [`fastdid`](https://cran.r-project.org/package=fastdid), [`staggered`](https://cran.r-project.org/package=staggered), [`did2s`](https://cran.r-project.org/package=did2s), [`didimputation`](https://cran.r-project.org/package=didimputation), [`fixest`](https://cran.r-project.org/package=fixest) with [Sun-Abraham](https://doi.org/10.1016/j.jeconom.2020.09.006)
- **IV:** `fixest::feols(y ~ x1 | fe | x2 ~ z)`, [`ivreg`](https://cran.r-project.org/package=ivreg) (standalone; also available via [`AER`](https://cran.r-project.org/package=AER))
- **RDD:** [`rdrobust`](https://cran.r-project.org/package=rdrobust), [`rddensity`](https://cran.r-project.org/package=rddensity), [`rdlocrand`](https://cran.r-project.org/package=rdlocrand)
- **Synthetic Control:** [`Synth`](https://cran.r-project.org/package=Synth), [`tidysynth`](https://cran.r-project.org/package=tidysynth), [`gsynth`](https://cran.r-project.org/package=gsynth), [`augsynth`](https://cran.r-project.org/package=augsynth)
- **Event Studies:** `fixest::i()`, [`did`](https://cran.r-project.org/package=did), [`eventstudyr`](https://cran.r-project.org/package=eventstudyr)
- **Inference:** [`sandwich`](https://cran.r-project.org/package=sandwich), [`clubSandwich`](https://cran.r-project.org/package=clubSandwich), [`wildrwolf`](https://cran.r-project.org/package=wildrwolf), [`fwildclusterboot`](https://cran.r-project.org/package=fwildclusterboot) (provides `boottest()`)

**Example invocation:**

```bash
/econometrics-check Paper/main.tex   # your main LaTeX manuscript
```

### Replication Auditor

Validates your replication package against the **AEA Data Editor standard** with 6 checks:

1. **Package Inventory** — all scripts, data files, and documentation present
2. **Dependency Verification** — R package versions recorded, `renv.lock` or equivalent
3. **Data Provenance** — sources documented, access instructions for restricted data
4. **Execution Verification** — runs scripts via Bash, checks for errors
5. **Output Cross-Reference** — every table/figure in the paper traced to a script
6. **README Completeness** — AEA-format README with numbered script descriptions

**Example invocation:**

```
/audit-replication Replication/
```

### Proofreader

Reviews `.tex` and `.qmd` files for:
- Grammar and typos
- Academic writing quality (no hedging language, effect sizes stated)
- Overfull hbox warnings
- Consistency (notation, terminology, abbreviations)
- LaTeX-specific issues (undefined references, broken citations)

### R-Reviewer

Reviews `.R` scripts for:
- Code quality (tidyverse idioms, no hardcoded paths)
- Reproducibility (`set.seed()`, package versions, relative paths)
- Econometric correctness (common pitfalls including TWFE staggered bias, wrong clustering level, missing first-stage diagnostics, weak IV detection, and deprecated `fixest` SE syntax)
- Figure quality (`ggplot2` theme consistency, publication-ready formatting)
- Professional standards (no `setwd()`, proper `library()` calls)

### Domain Reviewer

A template agent customizable for your specific field that cross-references with the econometrician for applied micro work. Reviews:
- Derivation correctness
- Assumption sufficiency
- Citation fidelity to seminal papers
- Code-theory alignment
- Logical consistency across sections

### Slide Auditor

For presentations in `Talks/`:
- Content overflow detection
- Font consistency across slides
- Box fatigue (too many styled environments)
- Spacing and alignment issues
- Timing estimates per format

### TikZ Reviewer

For any TikZ diagrams:
- Label positioning and overlap
- Visual consistency with document style
- Node alignment and arrow routing
- Color scheme compliance

### Verifier

End-to-end compilation and rendering:
- 3-pass XeLaTeX + BibTeX
- All `\ref{}` and `\cite{}` resolve
- No overfull hboxes above 1pt
- Figures exist at referenced paths
- Tables compile correctly

---

## Skills Reference

The Clo-Author ships with **26 slash commands** organized into 7 categories.

<div class="skill-grid skill-grid--2col" markdown="0">
<div class="skill-card">
<h4>Research & Ideation</h4>
<ul>
<li><code>/lit-review [topic]</code> — Literature search (top-5, NBER, field journals, SSRN/RePEc)</li>
<li><code>/research-ideation [topic]</code> — Research questions from descriptive to causal</li>
<li><code>/interview-me [topic]</code> — Interactive Q&A → research question + identification strategy</li>
</ul>
</div>
<div class="skill-card">
<h4>Writing</h4>
<ul>
<li><code>/draft-paper [section]</code> — Paper sections with econ structure</li>
<li><code>/proofread [file]</code> — Grammar, typos, writing quality</li>
<li><code>/compile-latex [file]</code> — 3-pass XeLaTeX + BibTeX</li>
</ul>
</div>
<div class="skill-card">
<h4>Econometrics</h4>
<ul>
<li><code>/econometrics-check [file]</code> — Causal design audit <span class="badge">NEW</span></li>
<li><code>/data-analysis [dataset]</code> — End-to-end R analysis</li>
<li><code>/review-r [file]</code> — R code + econometric correctness</li>
</ul>
</div>
<div class="skill-card">
<h4>Submission & Deposit</h4>
<ul>
<li><code>/target-journal [paper]</code> — Journal targeting <span class="badge">NEW</span></li>
<li><code>/respond-to-referee [report]</code> — Point-by-point response <span class="badge">NEW</span></li>
<li><code>/data-deposit</code> — AEA compliance <span class="badge">NEW</span></li>
<li><code>/audit-replication [dir]</code> — Validate replication package <span class="badge">NEW</span></li>
<li><code>/pre-analysis-plan [spec]</code> — PAP drafting <span class="badge">NEW</span></li>
</ul>
</div>
<div class="skill-card">
<h4>Presentations</h4>
<ul>
<li><code>/create-talk [format]</code> — Generate Beamer slides from paper <span class="badge">NEW</span></li>
<li><code>/visual-audit [file]</code> — Slide layout audit</li>
<li><code>/devils-advocate</code> — Challenge slide design</li>
</ul>
</div>
<div class="skill-card">
<h4>Quality Control</h4>
<ul>
<li><code>/paper-excellence [file]</code> — Multi-agent review <span class="badge">NEW</span></li>
<li><code>/review-paper [file]</code> — Top-journal referee simulation</li>
<li><code>/slide-excellence [file]</code> — Combined slide review</li>
<li><code>/validate-bib</code> — Cross-reference citations</li>
</ul>
</div>
</div>
<div class="skill-grid skill-grid--utility" markdown="0">
<div class="skill-card">
<h4>Utility</h4>
<ul>
<li><code>/commit [msg]</code> — Stage, commit, PR, merge</li>
<li><code>/learn</code> — Extract reusable knowledge into a skill</li>
<li><code>/context-status</code> — Check context usage and session health</li>
<li><code>/deploy</code> — Build and deploy project</li>
<li><code>/create-lecture [topic]</code> — Generate lecture slides (from template lineage)</li>
</ul>
</div>
</div>

### Skill Details

#### `/lit-review [topic]`

Produces a structured literature review targeting:
- **top-5 general journals** (AER, Econometrica, JPE, QJE, REStud)
- **NBER Working Papers** (recent, within 2-3 years)
- **Field journals** (JoLE, JHR, JDE, etc.)
- **SSRN/RePEc** working papers

Output includes: annotated bibliography, BibTeX entries, identification of research frontier (active debates, gaps), and suggested positioning for your paper.

#### `/draft-paper [section]`

Drafts paper sections with proper economics structure:
- **Introduction**: contribution paragraph within first 2 pages, effect sizes stated, clear identification preview
- **Empirical Strategy**: per-design template (DiD, IV, RDD, etc.) with assumption discussion
- **Results**: proper table/figure references, statistical vs economic significance
- **Notation protocol**: $Y_{it}$, $D_{it}$, $ATT(g,t)$ — consistent throughout

Anti-hedging rules enforced: no "interestingly", no "it is worth noting", no "arguably".

#### `/respond-to-referee [report]`

Classifies each referee comment into:
- **NEW ANALYSIS** — requires new estimation or data work
- **CLARIFICATION** — text revision sufficient
- **DISAGREE** — diplomatic pushback needed (flagged for your review)
- **MINOR** — typos, formatting

Produces a point-by-point response letter with diplomatic disagreement protocol and a tracking document in `quality_reports/`.

#### `/target-journal [paper]`

Given your paper (or abstract), produces:
- **Ranked journal list** (top-5, field, interdisciplinary) with fit rationale
- **Formatting requirements** per journal (word limits, citation style, figure format)
- **Submission checklist** (cover letter template, declarations, data availability)
- **Strategic notes** (editor preferences, recent similar publications, desk rejection risk)

#### `/paper-excellence [file]`

The flagship orchestration command. Launches all paper-quality agents **in parallel** — Econometrician, Proofreader, R-Reviewer, Domain Reviewer, and Replication Auditor — then aggregates their reports, applies fixes in priority order (critical → major → minor), re-verifies compilation, and scores the result against the quality gates (80/90/95). Runs up to 5 review-fix rounds autonomously.

#### `/create-talk [format]`

Generates Beamer `.tex` talks derived from your paper in 4 formats:

| Format | Slides | Duration | Content |
|--------|--------|----------|---------|
| Job Market | 40-50 | 45-60 min | Full story, all results, mechanism, robustness |
| Seminar | 25-35 | 30-45 min | Motivation, main result, 2 robustness checks |
| Short | 10-15 | 15 min | Question, method, key result, implication |
| Lightning | 3-5 | 5 min | Hook, result, so-what |

---

## Directory Structure

```
your-project/
├── Paper/                  # Main LaTeX manuscript (source of truth)
│   ├── main.tex
│   └── sections/           # \input{} files for each section
├── Talks/                  # Beamer presentations (4 formats)
│   ├── job_market_talk.tex
│   ├── seminar_talk.tex
│   ├── short_talk.tex
│   ├── lightning_talk.tex
│   └── preamble_talk.tex   # Shared Beamer preamble
├── Data/                   # Project data
│   ├── raw/                # Original untouched data (often gitignored)
│   └── cleaned/            # Processed datasets ready for analysis
├── Output/                 # Intermediate results (logs, temp files)
├── Figures/                # Final figures (.pdf, .png) referenced in paper
├── Tables/                 # Final tables (.tex) referenced in paper
├── scripts/R/              # Analysis scripts
├── Replication/            # AEA deposit package
├── Supplementary/          # Online appendix
├── Bibliography_base.bib   # Centralized bibliography
├── .claude/                # The workflow engine
│   ├── agents/             # 12 specialized reviewers
│   ├── skills/             # 26 slash commands
│   ├── rules/              # Quality standards & conventions
│   └── hooks/              # Automation triggers
├── quality_reports/        # Plans, reviews, session logs
│   ├── plans/
│   ├── session_logs/
│   └── specs/
└── CLAUDE.md               # Project constitution
```

**Paper/main.tex is the single source of truth.** Everything else — talks, tables, figures — derives from it. If the paper says $\beta = 0.15$ but a talk slide says $\beta = 0.12$, the talk is wrong.

---

## Customization Guide

### Adding Your Own Agent

Create a file at `.claude/agents/your-agent.md`:

```markdown
# Your Agent Name

**Role:** One-sentence description
**Access:** Read-only (never edits files)
**Tools:** Read, Grep, Glob

## Review Protocol

### Lens 1: [Name]
- Check A
- Check B

### Lens 2: [Name]
- Check C
- Check D

## Output Format
- Score: X/100
- Blocking issues: [list]
- Recommendations: [list]
```

### Creating a New Skill

Create a directory at `.claude/skills/your-skill/SKILL.md`:

```markdown
---
name: your-skill
description: What this skill does
user_invocable: true
---

# Skill: /your-skill

## Trigger
User types `/your-skill [arguments]`

## Workflow
1. Step one
2. Step two
3. Step three

## Output
What gets produced and where it is saved.
```

### Modifying Quality Gates

Edit `.claude/rules/quality-gates.md` to adjust:
- Score thresholds (80/90/95)
- Rubric weights per category
- Which deductions apply to your field
- Whether talk scores are blocking or advisory

---

## Design Philosophy

### Design-Opinionated, Package-Flexible

The Clo-Author has opinions about best practices:
- [Callaway-Sant'Anna](https://doi.org/10.1016/j.jeconom.2020.12.001) for staggered DiD
- [`fixest`](https://cran.r-project.org/package=fixest) for panel estimation
- [`rdrobust`](https://cran.r-project.org/package=rdrobust) for regression discontinuity
- [Romano-Wolf](https://doi.org/10.1080/01621459.2016.1226710) for multiple testing

But it **never flags alternative packages as errors**. If you use [`fastdid`](https://cran.r-project.org/package=fastdid) instead of [`did`](https://cran.r-project.org/package=did), or [`augsynth`](https://cran.r-project.org/package=augsynth) instead of [`Synth`](https://cran.r-project.org/package=Synth), the econometrician validates your implementation within that package's API. It notes the choice, checks correctness, and moves on.

### Zero Always-On Context Cost

All agents and skills are loaded **on demand**. Your `CLAUDE.md` (loaded every session) stays under 150 lines. The heavy documentation lives in agents, skills, and rules — only loaded when invoked.

### Archive, Do Not Delete

When infrastructure becomes obsolete (like lecture-specific tools), it moves to `archive/` subdirectories rather than being deleted. This preserves template value for users who need those features.

---

## FAQ

**Q: Do I need all 12 agents?**
No. The agents are invoked on demand. If you never write Beamer talks, the Slide Auditor and TikZ Reviewer never load. Start with `/econometrics-check` and `/paper-excellence` — those cover 80% of what you need.

**Q: Can I use this for structural/GE models?**
The current agents are optimized for reduced-form applied micro (DiD, IV, RDD, Synthetic Control, Event Studies). Structural models would need a custom agent, but the template makes adding one straightforward.

**Q: Does this work with Python?**
The R-Reviewer and econometrician are R-focused ([`fixest`](https://cran.r-project.org/package=fixest), [`did`](https://cran.r-project.org/package=did), [`rdrobust`](https://cran.r-project.org/package=rdrobust)). You could adapt the agents for Python equivalents ([`pyfixest`](https://github.com/py-econometrics/pyfixest), `statsmodels`, `linearmodels`, `rdrobust` for Python), but this is not built in yet.

**Q: How much does it cost?**
The Clo-Author is free and open source. You pay for Claude Code usage through Anthropic's API. Costs vary by session length and model; a typical 30-minute session (literature review + paper outline) costs a few dollars at current API rates.

**Q: Can I use this for teaching?**
Yes. The original [claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow) template was built for lecture production. The Clo-Author archives those tools but keeps them accessible in `.claude/skills/archive/` and `.claude/rules/archive/`.

---

## Origin & Credits

This project is a fork of [Pedro Sant'Anna's claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow), which was built for Econ 730 at Emory University (6 lectures, 800+ slides). The Clo-Author reorients that infrastructure from **lecture production** to **applied econometrics research publication**.

The core infrastructure (contractor mode, quality gates, context survival, session logging) comes from the original template. The econometrics-specific agents, paper drafting skills, and submission workflow are new.

---

## License

Open source under the [MIT License](https://github.com/hsantanna88/clo-author/blob/main/LICENSE). Fork it, customize it, make it yours.

[Fork on GitHub](https://github.com/hsantanna88/clo-author){: .btn .btn--primary}
