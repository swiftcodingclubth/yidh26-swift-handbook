# Code-along: Build your first app with coding agents

Coding agent คือ AI ที่อ่านโค้ดใน project, แก้ไฟล์, build และรันคำสั่งให้เราได้ ในช่วง hackathon ทีมที่ใช้ agent อย่างมีประสิทธิภาพจะทำงานได้มากกว่าทีมที่พิมพ์โค้ดเองทั้งหมดหลายเท่า

Workshop นี้ทุกคนจะได้ใช้ agent บนเครื่องของตัวเอง build feature แล้วรวมงานของทั้งทีมเป็น app เดียวกันบน GitHub

## สิ่งที่จะได้เรียน { #outcomes }

1. **Run app บน iPad ของตัวเอง**: สร้าง SwiftUI project แล้วติดตั้งลง iPad
2. **ใช้ Git และ GitHub กับทีม**: commit, branch, push, pull, merge และแก้ conflict ให้แต่ละคนทำ feature บน branch ของตัวเองแล้วรวมกันได้
3. **ใช้ coding agent ในการพัฒนาแอป**: ใช้ **Xcode agents** บน {{ mac.apple }} หรือ **OpenCode** บน {{ mac.intel }} ในการช่วยพัฒนาแอป

## แนวคิดหลัก { #concepts }

Coding agent สามารถแก้ไขโค้ดได้ทีละหลายไฟล์ในเวลาเพียงไม่กี่วินาที ถ้าผลลัพธ์ออกมาไม่ดี เราควรที่จะ revert โค้ดกลับทันทีโดนใช้ Git เพราะฉะนั้น เราควรที่จะ **commit โค้ดปัจจุบันก่อนให้ agent เริ่มงานทุกครั้ง**

| ขั้น | ทำอะไร |
|---|---|
| 1. Commit | ให้ working tree ไม่มีโค้ดค้างอยู่ |
| 2. Plan | เขียน prompt เพื่อให้ agent สร้าง plan ขึ้นมา |
| 3. Implement | Approve plan แล้วให้ agent เริ่มแก้ไขโค้ด |
| 4. Review | อ่าน diff ทุกไฟล์ แล้ว run แอปทดสอบ |
| 5. Push | Push branch แล้วเปิด pull request เพื่อที่จะ merge เข้า branch `main` |

## MacBook แต่ละเครื่องทำอะไรได้บ้าง { #machines }

ทุกคนมี agent ใช้ แต่คนละตัว

!!! mchip "{{ mac.apple }} · Xcode 27"
    ใช้ **Xcode agents** ใน panel ของ Xcode 27 ดู [Xcode agents](xcode-agents.md)

!!! intel "{{ mac.intel }} · Xcode 26"
    ใช้ **OpenCode** ใน Terminal เปิดคู่กับ Xcode 26 ดู [OpenCode](opencode.md)

| | Xcode agents · {{ mac.apple }} | OpenCode · {{ mac.intel }} |
|---|---|---|
| Model | Claude, Codex หรือ Antigravity | Free model จาก OpenCode Zen เปลี่ยนเป็นโมเดลอื่นๆได้ภายหลัง |
| แก้โค้ด, ใช้ Git | ✓ | ✓ |
| ค่าใช้จ่าย | subsciption หรือ API key | ฟรี |

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

สร้างแอปที่มีชื่อว่า **Team Card** ที่สามารถแสดงรายชื่อสมาชิกในทีม และกดไปหน้ารายละเอียดของสมาชิกแต่ละคนได้

1. **Commit และสร้าง branch** ใหม่ ดู [Workflow ของทีม](git.md#workflow)
2. **เขียน prompt** ตาม [template](prompting.md#prompt-template) แล้วขอ plan
3. **อ่าน plan** แก้ส่วนที่ไม่ใช่ แล้วให้ agent ลงมือ ดู [Xcode agents](xcode-agents.md#workflow-plan-build-review-commit) หรือ [OpenCode](opencode.md#plan-mode-build-mode)
4. **Build แล้ว run** บน iPad
5. **Review diff** ทุกไฟล์ แล้ว commit และ push

!!! tip "ตามไม่ทัน"
    ถ้า agent แก้โค้ดแล้วพัง ให้ Discard All Changes แล้วเขียน prompt ใหม่ที่ละเอียดมากขึ้น

### 2. Team challenge

ฝึก workflow การทำงานในโปรเจคเดียวกันร่วมกันกับสมาชิกในทีม

1. **เลือก feature** ที่แต่ละคนจะพัฒนา
2. **สร้าง branch** เพื่อพัฒนา feature นั้นของตัวเอง เช่น `feature/search-item`
3. **Build feature** ด้วย agent ของตัวเอง
4. **Merge feature**: merge ทุก branch เข้า `main` แล้ว run app บน iPad เพื่อตรวจสอบว่าทุก feature ถูก merge เรียบร้อย

!!! tip "ตามไม่ทัน"
    Merge เฉพาะ branch ที่เสร็จแล้วก่อน ถ้าติดปัญหา merge conflict ที่แก้ไม่ได้ ให้ agent ช่วยแก้ตาม[วิธีนี้](git.md#conflict) หรือเรียก TA
