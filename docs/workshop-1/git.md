# Git & GitHub

**Git** คือระบบเก็บประวัติการแก้ไขของ project ทุกครั้งที่ commit Git จะจำสภาพของไฟล์ทั้งหมดไว้ ถ้า agent แก้โค้ดพัง เราย้อนกลับไปจุดที่ commit ไว้ได้เสมอ **ถ้า commit ไว้ก่อน**

**GitHub** คือเว็บที่เก็บ repo ของทีมไว้ online ทุกคนในทีม push งานขึ้นไปและ pull งานของเพื่อนลงมาจากที่เดียวกัน

ทุก operation ด้านล่างทำได้จากเมนู **Integrate** และ Source Control navigator ใน Xcode หรือสั่งให้ agent ทำให้ก็ได้ สิ่งสำคัญคือเข้าใจว่าแต่ละอย่างทำอะไร และควรใช้เมื่อไหร่

## Operations ที่ต้องรู้ { #operations }

### เก็บงานบนเครื่องเรา

**Repository (repo)** คือ folder ของ project ที่ Git ติดตามประวัติไว้ทั้งหมด ทีมมี repo กลางบน GitHub หนึ่งอัน และแต่ละคนมีสำเนาบนเครื่องตัวเอง

**Clone** คือการดาวน์โหลด repo จาก GitHub มาที่เครื่องเป็นครั้งแรก ทำครั้งเดียวตอนเริ่มต้น

**Diff** คือการดูว่าไฟล์ไหนถูกแก้ และแก้บรรทัดไหนไปบ้างตั้งแต่ commit ล่าสุด ใช้ทุกครั้งหลัง agent ทำงานเสร็จ เพื่อ review ก่อน commit

**Commit** คือการบันทึก snapshot ของไฟล์ทั้งหมด ณ ตอนนั้น พร้อมข้อความอธิบายว่าทำอะไร เป็นจุดที่เราย้อนกลับมาได้เสมอ ควร commit ก่อนให้ agent เริ่มงาน และหลังงานเสร็จที่ build ผ่านแล้ว

### แบ่งงานกับเพื่อน

**Branch** คือการแยกสายงานออกมาจาก `main` แต่ละคนทำ feature บน branch ของตัวเองได้โดยไม่กระทบงานของเพื่อน จนกว่าจะ merge เข้าด้วยกัน

**Merge** คือการรวมงานจาก branch หนึ่งเข้าอีก branch เช่น รวม `feature/search` เข้า `main` เมื่อ feature เสร็จ

### อัปเดตงานไปที่ GitHub

**Push** คือการส่ง commit บนเครื่องเราขึ้นไปที่ GitHub เพื่อนจึงจะเห็นงานของเรา

**Pull** คือการดึง commit ใหม่จาก GitHub ลงมาที่เครื่องเรา ควร pull ก่อนเริ่มงานทุกครั้ง จะได้มีงานล่าสุดของเพื่อนครบ

**Pull request (PR)** คือการขอ merge branch ของเราบน GitHub ให้เพื่อนได้ดู diff และ review ก่อนรวมเข้า `main`

### ย้อนกลับ

**Discard changes** คือการทิ้งการแก้ไขทั้งหมดที่ยังไม่ได้ commit กลับไปเหมือน commit ล่าสุด ใช้เมื่อ agent แก้แล้วผลไม่ดี

**Revert** คือการสร้าง commit ใหม่ที่ย้อนผลของ commit เก่า ใช้เมื่อ commit ไปแล้วถึงพบว่าผิด ประวัติเดิมยังอยู่ครบ

## Workflow ของทีม { #workflow }

ทำแบบนี้ทุกครั้งที่เริ่ม feature ใหม่

1. **เริ่มจาก `main` ล่าสุด** สลับไป `main` แล้ว pull ถ้าลืม pull จะทำงานบนโค้ดเก่า แล้ว conflict ตอน merge
2. **สร้าง branch** ตั้งชื่อตาม feature เช่น `feature/search` งานของเราจะแยกจากของเพื่อนจนกว่าจะ merge
3. **ให้ agent ทำงาน แล้ว review diff** อ่านทุกไฟล์ที่ถูกแก้ build ให้ผ่าน แล้วลองบน iPad
4. **Commit** เขียนข้อความบอกว่าทำอะไร เช่น "Add search bar" ไม่ใช่ "update"
5. **Push และเปิด pull request** บน GitHub ให้เพื่อน review แล้ว merge เข้า `main`

## แก้ conflict { #conflict }

Conflict เกิดเมื่อสอง branch แก้ **บรรทัดเดียวกัน** ในไฟล์เดียวกัน Git ตัดสินใจเองไม่ได้ว่าจะเอาของใคร จึงให้เราเลือก ไม่ใช่ error ร้ายแรง แค่ต้องตัดสินใจ

1. Pull หรือ merge แล้ว Xcode จะแสดงไฟล์ที่ conflict
2. เปิดไฟล์ จะเห็นทั้งสองฝั่งคั่นด้วยเครื่องหมายแบบนี้

    ```text
    <<<<<<< HEAD
    Text("Team Card")        ← ของเรา
    =======
    Text("Our Team")         ← ของเพื่อน
    >>>>>>> feature/title
    ```

3. เลือกว่าจะเก็บฝั่งไหน หรือรวมทั้งสองฝั่ง แล้วลบเครื่องหมาย `<<<<<<<`, `=======`, `>>>>>>>` ออกให้หมด
4. Build ให้ผ่านก่อน แล้ว commit

!!! tip "ให้ agent ช่วยแก้ conflict ได้"
    เช่น prompt ว่า "Resolve the merge conflicts in TeamListView.swift, keep both features, then build." แล้ว review ผลก่อน commit

## `.gitignore` สำหรับ Xcode

ไฟล์ `.gitignore` บอก Git ว่าไฟล์ไหน **ไม่ต้อง** เก็บ เช่น ไฟล์ตั้งค่าส่วนตัวของ Xcode ที่ทำให้ conflict โดยไม่จำเป็น และไฟล์ที่มี API key

```gitignore
xcuserdata/
DerivedData/
*.xcuserstate
.DS_Store
Secrets.plist
```

## ปัญหาที่เจอบ่อย

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| Push ไม่ได้ (rejected) | เพื่อน push ขึ้นไปก่อน GitHub มี commit ที่เรายังไม่มี | Pull ก่อน แล้วค่อย push |
| Commit ผิด branch | ลืมสร้างหรือสลับ branch ก่อนเริ่มงาน | ถาม TA อย่าเพิ่ง push |
| Detached HEAD | Checkout ไปที่ commit เก่าแทน branch | สลับกลับไป `main` (ถ้ามีงานค้าง ให้ถาม TA ก่อน) |
| Conflict ใน `.pbxproj` | หลายคนเพิ่มหรือลบไฟล์ใน project พร้อมกัน | ให้คนเดียวเพิ่ม/ลบไฟล์ในแต่ละช่วง และ pull ก่อนเพิ่มไฟล์ |
