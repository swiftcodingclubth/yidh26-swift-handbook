# Xcode agents

!!! mchip "{{ mac.apple }} · Xcode 27"
    Xcode agents ใช้ได้เฉพาะ {{ mac.apple }} {{ mac.intel }} ใช้ไม่ได้ ให้ใช้ [OpenCode](opencode.md) แทน

Xcode 27 มี coding agent อยู่ใน panel ของ Xcode เลย เลือกได้ทั้ง **Claude**, **Codex** และ **Antigravity** ใช้ account ของทีมที่ sign in ไว้แล้วบนเครื่อง ไม่ต้องตั้งค่าเพิ่ม

ข้อดีของการอยู่ใน Xcode คือ agent เห็นสิ่งเดียวกับที่เราเห็น: build เองได้ ดู error เองได้ และดู Preview ของหน้าจอที่มันสร้างได้ จึงแก้ปัญหาเองได้หลายรอบโดยไม่ต้องให้เราคอยบอก

## Agent ทำอะไรได้บ้าง

- **อ่านและแก้ไฟล์ใน project** ทั้งไฟล์ที่เปิดอยู่และไฟล์อื่นที่เกี่ยวข้อง
- **Build และ run tests** แล้วอ่าน error เพื่อแก้ต่อเอง
- **ค้นหา documentation** ได้ข้อมูล API ที่ถูกต้องและใหม่กว่าความรู้ของ model
- **ดู SwiftUI Preview** เพื่อตรวจว่า UI ที่สร้างหน้าตาถูกต้อง
- **ใช้ agent skills ของ Apple** ที่สอนให้เขียน Swift และ SwiftUI แบบสมัยใหม่

## Permissions

ก่อนแก้ไฟล์หรือรันคำสั่ง agent จะขออนุญาตก่อน อ่านทุกครั้งว่ามันจะทำอะไรก่อนกด allow โดยเฉพาะคำสั่งที่ลบไฟล์ เปลี่ยน project settings หรือเพิ่ม package ถ้าไม่เข้าใจว่าคำสั่งทำอะไร ให้ถาม agent ก่อน

!!! warning "Usage limit"
    Account ของทีมมี usage limit ที่ต้องบริหารการใช้งานตลอด hackathon เพราะฉะนั้น เลือกใช้ agent กับงานที่เหมาะสม เช่น feature ใหม่หรือ bug ที่ใช้เวลาแก้ไขนาน
