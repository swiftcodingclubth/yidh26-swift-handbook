# Prompting, guardrails & best practices

Agent ทำงานได้ดีแค่ไหนขึ้นกับ prompt ที่ได้รับ prompt ที่คลุมเครือจะได้โค้ดที่เดาเอาเอง แก้ไฟล์ที่ไม่เกี่ยว หรือทำเกินที่ขอ หน้านี้รวมวิธีเขียน prompt ให้ได้ผลตรงที่ต้องการ และกติกาที่ทำให้ใช้ agent ได้อย่างปลอดภัย

## Prompt template

ใช้ได้กับทั้ง Xcode agents และ OpenCode และมีใน repo ของทีมเป็น GitHub issue template ด้วย

```text
GOAL:        Add a search bar that filters the team list by name.
CONTEXT:     TeamListView.swift, TeamMember.swift
CONSTRAINTS: SwiftUI only, iOS 26 deployment target, no iOS 27-only APIs,
             no new packages.
DONE WHEN:   It builds, filtering works in the Preview,
             and existing features still work.
PROCESS:     Show me a plan first. Wait for my approval before editing.
```

| ส่วน | ใส่อะไร | ทำไม |
|---|---|---|
| **GOAL** | ผลลัพธ์ที่ต้องการ 1 อย่าง ชัดเจน | Agent รู้ว่าต้องทำอะไร และไม่ทำเกิน |
| **CONTEXT** | ไฟล์หรือหน้าจอที่เกี่ยวข้อง | Agent ไม่ต้องเดาว่าต้องแก้ตรงไหน |
| **CONSTRAINTS** | ข้อห้ามและข้อจำกัด เช่น iOS 26, ห้ามเพิ่ม package | ป้องกันโค้ดที่เพื่อนบน {{ mac.intel }} build ไม่ผ่าน |
| **DONE WHEN** | วิธีตรวจว่างานเสร็จจริง | Agent ตรวจงานตัวเองได้ก่อนส่ง |
| **PROCESS** | ขอ plan ก่อนลงมือเสมอ | เราได้แก้ความเข้าใจผิดก่อนที่จะมีโค้ด |

Prompt เขียนเป็นภาษาไทยหรืออังกฤษก็ได้ แต่ชื่อไฟล์ ชื่อ type และศัพท์เทคนิคให้เขียนตามในโค้ด

## Prompt ดี vs ไม่ดี

| ✗ ไม่ดี | ✓ ดี | ต่างกันตรงไหน |
|---|---|---|
| "ทำ app ให้สวยขึ้น" | "Add dark mode support to TeamCardView using system colors." | บอกหน้าจอและวิธีที่ต้องการ แทนคำว่า "สวย" ที่ agent ต้องเดา |
| "แก้ bug" | "Tapping Save crashes with index out of range in TeamStore.swift line 42. Find the cause and fix it." | บอกอาการ, error และตำแหน่ง agent หาสาเหตุได้ทันที |
| "เพิ่ม feature ทั้งหมดตาม idea" | แบ่งเป็น task เล็กๆ ทีละ feature | งานใหญ่ทำให้ agent หลงทางและ review ยาก |

## Guardrails

!!! danger "ห้ามทำ"
    - **ใส่ API key, password หรือข้อมูลส่วนตัวใน prompt** prompt ถูกส่งไปที่ server ของ model
    - **Commit `Secrets.plist` หรือ key ใดๆ** ถ้าขึ้น GitHub แล้ว ลบทีหลังก็ยังอยู่ในประวัติ
    - **ใช้ข้อมูลผู้ป่วยจริง** ใช้ synthetic data เท่านั้น
    - **กด allow คำสั่งที่ไม่เข้าใจ** ถาม agent ก่อนว่าคำสั่งนั้นทำอะไร

!!! success "ต้องทำทุกครั้ง"
    - **Commit ก่อนให้ agent เริ่มงาน** จะได้ย้อนกลับได้ในครั้งเดียว
    - **อ่าน plan ก่อน approve** แก้ plan ง่ายกว่าแก้โค้ด
    - **Review diff ทุกไฟล์ก่อน commit** ดูว่าไม่มีการแก้ไฟล์ที่ไม่เกี่ยว
    - **Run บน iPad จริงก่อน push** build ผ่านไม่ได้แปลว่าทำงานถูก

## `AGENTS.md`

`AGENTS.md` คือไฟล์ที่อธิบาย project และกติกาให้ agent วางไว้ที่ root ของ repo agent จะอ่านไฟล์นี้ก่อนเริ่มงานทุกครั้ง จึงไม่ต้องพิมพ์กติกาเดิมซ้ำในทุก prompt และทุก agent ในทีมจะทำตามกติกาเดียวกัน

ทีมใช้ Xcode สองเวอร์ชัน {{ mac.apple }} ใช้ Xcode 27 ส่วน {{ mac.intel }} ใช้ Xcode 26 ซึ่ง build โค้ดที่ใช้ API ของ iOS 27 ไม่ได้ Agent ไม่รู้เรื่องนี้เอง ถ้าไม่บอก มันมักเลือกใช้ API ใหม่ล่าสุด แล้วโค้ดจะ build ไม่ผ่านบนเครื่องของเพื่อนอีก 2 คน `AGENTS.md` ที่เตรียมไว้ให้จะบอกเรื่องนี้กับ agent ทุกครั้ง

### เริ่มใช้งาน

ทำครั้งเดียวต่อทีม บนเครื่องใดก็ได้

1. **Copy `AGENTS.md` จาก Desktop** ไปวางใน folder ของ project ระดับเดียวกับไฟล์ `.xcodeproj`
2. **แก้บรรทัดใต้ `## About this app`** เป็นประโยคเดียวที่อธิบาย app ของทีม
3. **Commit และ push** เพื่อให้ agent ทุกเครื่องในทีมอ่านไฟล์เดียวกัน

### เนื้อหาในไฟล์

````markdown title="AGENTS.md"
# AGENTS.md

Rules for any coding agent (Xcode agents, OpenCode, or others) working in this project.

## About this app
<!-- Team: replace this line with one sentence about your app. -->
A SwiftUI app for iPad, built by a team of 3 at the Young iOS Developer Hackathon 2026.

## Our team uses TWO Xcode versions. Code must build in BOTH.
- 1 M-chip Mac with **Xcode 27** (iOS 27 SDK).
- 2 Intel Macs with **Xcode 26** (iOS 26 SDK). These Macs cannot build iOS 27-only code.
- If code builds in Xcode 27 but not in Xcode 26, it is broken for 2 of our 3 teammates.

## Hard rules
1. **Deployment target stays iOS 26.0.** Do not change it.
2. **Do not use iOS 27-only APIs** unless the user asks for one. When they do, wrap it like this so Xcode 26 still compiles:
   ```swift
   #if compiler(>=6.4)   // Swift 6.4 ships with Xcode 27
   if #available(iOS 27, *) {
       // iOS 27-only code
   }
   #endif
   ```
   For a framework that only exists in the iOS 27 SDK, also guard the import with `#if canImport(FrameworkName)`.
3. **Do not change project settings.** This includes the project format, the signing team, the bundle identifier and the deployment target. Do not accept "Update to recommended settings."
4. **Do not edit `project.pbxproj` by hand.** Put new Swift files inside the app's source folder. Xcode picks them up automatically.
5. **No new Swift packages or dependencies** unless the user approves them first.
6. **Never put secrets in code or commits.** That means API keys, passwords, tokens or personal data.

## How to work
- **Plan first.** Show a short plan and the files you will change. Wait for approval before editing.
- Keep each task small: one feature or one fix at a time.
- Work on the current feature branch. Never commit to `main`, never force-push and never rewrite history.
- After changing code, build it. On the command line, use:
  `xcodebuild -scheme <SchemeName> -destination 'generic/platform=iOS Simulator' build`
- Finish by listing what you changed and how the user can test it (Preview, Simulator or iPad).

## Code style
- SwiftUI only (no UIKit unless needed). One main view per file.
- Add a `#Preview` for every new view.
- Use clear names and short functions. Add comments only where the code isn't obvious.

## Talking to the user
- The user is a high-school student. Explain changes simply.
- Reply in the language the user writes in (Thai or English).
````
