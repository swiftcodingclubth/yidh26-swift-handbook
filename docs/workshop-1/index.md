# Code-along: Build your first app with coding agents

Coding agent คือ AI ที่อ่านโค้ดใน project, แก้ไฟล์, build และรันคำสั่งให้เราได้ ในช่วง hackathon ทีมที่ใช้ agent เป็นจะทำงานได้มากกว่าทีมที่พิมพ์โค้ดเองทั้งหมดหลายเท่า แต่ต้องรู้วิธี **วางแผน → มอบงาน → ตรวจผล → ส่งงาน** ให้ถูก

Workshop นี้ทุกคนจะได้ใช้ agent บนเครื่องของตัวเอง build feature แล้วรวมงานของทั้งทีมเป็น app เดียวบน GitHub เป็นพื้นฐานของทุก workshop ช่วงบ่าย

## สิ่งที่จะได้เรียน { #outcomes }

1. **Run app บน iPad ของตัวเอง**: สร้าง SwiftUI project แล้วติดตั้งลง iPad ด้วย Apple ID ฟรี
2. **ใช้ Git และ GitHub กับทีม**: commit, branch, push, pull, merge และแก้ conflict ให้แต่ละคนทำ feature บน branch ของตัวเองแล้วรวมกันได้
3. **ใช้ coding agent ครบ loop**: plan → implement → build → review diff → test บน iPad → commit ด้วย **Xcode agents** บน {{ mac.apple }} หรือ **OpenCode** บน {{ mac.intel }}
4. **ใช้ agent อย่างปลอดภัย**: ไม่ใส่ข้อมูลลับใน prompt, แบ่งงานให้เล็ก และรู้ว่าเมื่อไหร่ควรหยุดแล้วย้อนกลับ

## แนวคิดหลัก { #concepts }

Agent แก้โค้ดได้ทีละหลายไฟล์ในเวลาไม่กี่วินาที ถ้าผลออกมาไม่ดี เราต้องย้อนกลับได้ทันที Git คือสิ่งที่ทำให้ย้อนกลับได้ จึงมีกฎข้อเดียวของวันนี้: **commit ก่อนให้ agent เริ่มงานทุกครั้ง**

ทุกงานที่ให้ agent ทำ วนตาม loop เดียวกัน:

| ขั้น | ทำอะไร | ดู |
|---|---|---|
| 1. Commit | ให้ working tree สะอาด ถ้าผลไม่ดีจะย้อนกลับได้ในครั้งเดียว | [Workflow ของทีม](git.md#workflow) |
| 2. Plan | เขียน prompt ตาม template แล้วขอ plan ก่อน อย่าให้แก้โค้ดทันที | [Prompt template](prompting.md#prompt-template) |
| 3. Implement | Approve plan แล้วให้ agent แก้โค้ดและ build จนผ่าน | [Xcode agents](xcode-agents.md) · [OpenCode](opencode.md) |
| 4. Review | อ่าน diff ทุกไฟล์ แล้ว run บน iPad | [Guardrails](prompting.md#guardrails) |
| 5. Push | Push branch แล้วเปิด pull request | [Git operations](git.md#operations) |

## MacBook แต่ละเครื่องทำอะไรได้บ้าง { #machines }

ทุกคนมี agent ใช้ แต่คนละตัว

!!! mchip "{{ mac.apple }} · Xcode 27"
    ใช้ **Xcode agents** ใน panel ของ Xcode 27 ดู [Xcode agents](xcode-agents.md)

!!! intel "{{ mac.intel }} · Xcode 26"
    ใช้ **OpenCode** ใน Terminal เปิดคู่กับ Xcode 26 ดู [OpenCode](opencode.md)

| | Xcode agents · {{ mac.apple }} | OpenCode · {{ mac.intel }} |
|---|---|---|
| ใช้ที่ไหน | Panel ใน Xcode 27 | Terminal เปิดคู่กับ Xcode 26 |
| Model | Claude, Codex หรือ Gemini ผ่าน account ของทีม | Free model จาก OpenCode Zen เปลี่ยนได้ภายหลัง |
| แก้โค้ด, ใช้ Git | ✓ | ✓ |
| Build project | ✓ ผ่าน Xcode | ✗ เรา build เองใน Xcode แล้วส่ง error ให้ agent แก้ |
| ดู SwiftUI Preview | ✓ ตรวจ UI ที่ตัวเองสร้างได้ | ✗ เราต้องดูเองใน Xcode |
| ค้น Apple documentation | ✓ | ✗ ใช้ความรู้ของ model และ `AGENTS.md` |
| ค่าใช้จ่าย | ใช้ usage ของ account ทีม | ฟรี |

## หัวข้อหลัก { #pages }

| หน้า | เนื้อหา |
|---|---|
| [Hardware](hardware.md) | อุปกรณ์ของทีม และเครื่องไหนทำอะไรได้ |
| [Git & GitHub](git.md) | Git operations ที่ต้องรู้, workflow ของทีม และวิธีแก้ conflict |
| [Xcode agents](xcode-agents.md) | ใช้ agent ใน Xcode 27 บน {{ mac.apple }} |
| [OpenCode](opencode.md) | ใช้ agent ใน Terminal บน {{ mac.intel }} |
| [Prompting & best practices](prompting.md) | Prompt template, สิ่งที่ห้ามทำ และเทคนิคให้ agent ทำงานได้ดี |

## ลงมือปฏิบัติ { #hands-on }

### 1. Guided build: Team Card

ทุกคนสร้าง feature เดียวกันพร้อมกัน คือหน้า **Team Card** ที่แสดงรายชื่อสมาชิกในทีม กดแล้วไปหน้ารายละเอียด ผู้สอนจะสลับระหว่าง Xcode 27 และ OpenCode บนจอใหญ่ให้ตามได้ทั้งสองแบบ

1. **Commit และสร้าง branch** ใหม่ ดู [Workflow ของทีม](git.md#workflow)
2. **เขียน prompt** ตาม [template](prompting.md#prompt-template) แล้วขอ plan
3. **อ่าน plan** แก้ส่วนที่ไม่ใช่ แล้วให้ agent ลงมือ ดู [Xcode agents](xcode-agents.md#workflow-plan-build-review-commit) หรือ [OpenCode](opencode.md#plan-mode-build-mode)
4. **Build แล้ว run** บน iPad
5. **Review diff** ทุกไฟล์ แล้ว commit และ push

!!! tip "ตามไม่ทัน"
    ถ้า agent แก้แล้วพัง ให้ Discard All Changes แล้วเขียน prompt ใหม่ที่ชัดขึ้น ถ้ายังไม่ทัน checkout branch [`checkpoint/team-card`] ที่ทำเสร็จไว้ให้ แล้วไปต่อที่ Team challenge

### 2. Team challenge

ฝึก workflow เดียวกับที่จะใช้จริงตลอด hackathon: 3 คน 3 agent ทำงานพร้อมกัน แล้วรวมเป็น app เดียว

1. **เลือก feature** ที่ไม่ซ้ำกัน: search, ปรับ dark mode, share button, settings screen หรือ animation
2. **สร้าง branch** ของตัวเอง เช่น `feature/search` จะได้ไม่ชนกับงานของเพื่อน
3. **Build feature** ด้วย agent ของตัวเอง แล้ว run บน iPad ของตัวเอง ดู [Best practices](prompting.md#best-practices)
4. **Merge** 8 นาทีสุดท้าย: merge ทุก branch เข้า `main` แก้ conflict ด้วยกัน แล้ว run app ที่รวมแล้วบน iPad ทุกเครื่อง ดู [แก้ conflict](git.md#conflict)

!!! tip "ตามไม่ทัน"
    Merge เฉพาะ branch ที่เสร็จแล้วก่อน ถ้าติด conflict ที่แก้ไม่ได้ ให้ agent ช่วยแก้ตาม[วิธีนี้](git.md#conflict) หรือเรียก TA
