# Speaker guide: workshop page format

Every workshop in this handbook follows the same shape, so a participant who has used one workshop knows where to look in the next. The handbook is a **quick reference and summary** to keep open beside Xcode during and after the session. It is not a transcript of your talk: slides carry the story, the handbook carries what people need to copy, check, or come back to at 2 a.m. during the hackathon.

Copy-paste skeletons: [`templates/workshop-index.md`](templates/workshop-index.md) and [`templates/topic-page.md`](templates/topic-page.md).

## Folder layout

```
docs/workshop-N/
├── index.md       # landing page: fixed sections below
└── <topic>.md     # 3–6 topic pages, one per framework, tool or skill
```

- File names: English, kebab-case (`core-motion.md`, `tool-calling.md`).
- Add the folder to `nav` in `mkdocs.yml` and fill in the workshop card in `docs/index.md`.

## Landing page (`index.md`)

Use these sections **in this order, with these exact headings and anchors**. The fixed `{ #id }` anchors matter: Thai headings get no automatic anchor, and fixed ones let anyone link to e.g. `workshop-4/index.md#machines`. Do not add other H2 sections; anything that does not fit belongs in a topic page.

| # | Heading | What goes in it | Budget |
|---|---|---|---|
| – | `# <session title>` + intro | What this workshop is about and what it lets a team's app do. How it relates to other workshops. | ≤ 2 short paragraphs |
| 1 | `## สิ่งที่จะได้เรียน { #outcomes }` | Learning outcomes | Numbered list, max 4 items, `**Bold verb phrase**: one sentence` |
| 2 | `## แนวคิดหลัก { #concepts }` | The one mental model to remember: a "ถ้าต้องการ… ใช้…" table, a comparison table, or one short code block | ≤ 1 screen; H3s allowed |
| 3 | `## MacBook แต่ละเครื่องทำอะไรได้บ้าง { #machines }` | What works on which machine and the workaround | `mchip` admonition, then `intel`; one sentence if no difference |
| 4 | `## หัวข้อหลัก { #pages }` | Topic pages in reading order | table `หน้า \| เนื้อหา`, one line each |
| 5 | `## ลงมือปฏิบัติ { #hands-on }` | What participants build, step by step | 1 build, or 2–3 tracks |

### Planning your session

The handbook does not include the event schedule, a per-session agenda, or session duration and room. When planning your 90–120 minutes, keep at least 40% hands-on:

| Block | 90 min | 120 min |
|---|---|---|
| Intro + แนวคิดหลัก | 10 | 15 |
| Code-along through topic pages | 30 | 40 |
| Hands-on | 40 | 50 |
| Wrap-up and Q&A | 10 | 15 |

### ลงมือปฏิบัติ

```markdown
## ลงมือปฏิบัติ { #hands-on }

### <ชื่อ app หรือ feature>

<หนึ่งประโยค: สร้างอะไร>

1. **<กริยา>** <ทำอะไร> ดู [<topic>](<topic>.md#<anchor>)
2. ...

!!! tip "ตามไม่ทัน"
    <checkpoint branch, backup dataset, หรือขอจาก TA>
```

- 4–7 steps. Each starts with a **bold verb** and links to the topic page that explains it; do not re-explain the API here.
- Always give a catch-up path (checkpoint branch, backup dataset) so nobody is stuck for the rest of the session.
- Several options: one `### Track: <name>` per track. A build followed by a team exercise: `### 1. …` and `### 2. …`.

## Topic pages

```
# <Topic>
[!!! mchip / intel]         only if the topic works on one machine only
<intro>                      **Name** คือ … · what it's for · availability
## Setup                     optional: package, Info.plist, permission, device check
## <1. task> … ## <N. task>  the content
## ปัญหาที่เจอบ่อย            optional
## ใช้ร่วมกับ                  optional: links to other pages and workshops
## ไปต่อ                      optional: things not covered in the session, for later in the hackathon
```

Reference pages (cheat sheets, hardware lists, prompt templates) can skip the task sections and go straight to tables, but keep the intro and the closing sections.

- **Intro**: start with `**<Name>** คือ …` in plain words, then what you'd use it for in an app. If it works on both machines, end with "ใช้ได้ทั้ง Xcode 26 และ 27". If not, put the `mchip`/`intel` admonition directly under the H1, including how to guard the code (`#if compiler(>=6.4)`).
- **Name sections after tasks, not APIs**: "วัดระยะที่จุดกลางจอ", not "ARFrame". Number them (`## 1. …`) when each builds on the previous one.
- **Each task section**: 1–2 sentences on why → one code block → 1–2 sentences on what happens and what to watch for.
- **Code**: ≤ ~30 lines per block. Anything longer, or anything that must compile, lives in the starter repo and is included with `--8<-- "path/File.swift:section"`.
- **Troubleshooting**: a table `อาการ | สาเหตุ | วิธีแก้`. Use `!!! failure "<error message>"` for a single exact error.
- **Optional extras** that are not part of the session (export your own model, advanced options) go in a collapsed `??? note` or at the end under `## ไปต่อ`.
- **Length**: ≤ ~150 lines. Split the page if it grows past that.

## Writing conventions (all pages)

- Thai text, technical terms in English. Short sentences. Talk to the reader ("ให้…", "ถ้า…").
- Machine names: always `{{ mac.apple }}` / `{{ mac.intel }}`, never typed out.
- Link to the page that explains something instead of explaining it twice.
- Placeholders in `[brackets]` must be filled before print.
- At most one admonition per section, and only with this meaning:

| Admonition | Use for |
|---|---|
| `mchip` / `intel` | Works differently or only on one machine |
| `tip` | A shortcut, a better way, or a catch-up path |
| `note` | An important fact that is not a risk |
| `warning` | Something that will break, crash, or cost (battery, usage limit) |
| `danger` | Secrets, privacy, health data |
| `failure` | One exact error message and its fix |
| `??? note` (collapsed) | Optional material: install on another machine, deep dive |
| `review` | A comment for the speaker to fix (red box). Remove it once fixed, before print |

## Before you submit

- [ ] Landing page has all sections, in order, with the fixed anchors
- [ ] Every ลงมือปฏิบัติ step links to a topic page, and there is a catch-up path
- [ ] Every topic page says which machines it works on
- [ ] Code blocks ≤ ~30 lines; longer code is in the starter repo
- [ ] Workshop added to `nav` in `mkdocs.yml` and its card in `docs/index.md` is filled in
- [ ] `mkdocs serve` builds without warnings or broken links
