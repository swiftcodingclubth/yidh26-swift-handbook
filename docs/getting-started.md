# เริ่มต้นใช้งาน

## ก่อนวันงาน

- [ ] สร้าง **Apple ID** (ฟรี ไม่ต้องสมัคร Apple Developer Program)
- [ ] สร้าง **GitHub account** แล้วส่ง username ให้ผู้จัด
- [ ] ลองอ่าน [Git & GitHub](workshop-1/git.md) ถ้ายังไม่เคยใช้ Git

## วันงาน: Setup 5 ขั้นตอน

### 1. เช็ก Team card

แต่ละทีมจะได้ Team card ที่มีข้อมูลเหล่านี้

- Team number และ URL ของ GitHub repo
- API key สำหรับ AI cluster
- Wi-Fi ของงาน

!!! warning "Team card เป็นความลับ"
    ห้ามถ่ายรูปโพสต์ และห้าม commit key ลง repo

### 2. Sign in Xcode ด้วย Apple ID

**Xcode › Settings › Accounts › `+` › Apple ID**

Xcode จะสร้าง team ชื่อ *ชื่อคุณ (Personal Team)* ให้อัตโนมัติ

### 3. เปิด Developer Mode บน iPad

**Settings › Privacy & Security › Developer Mode › On** แล้ว restart iPad

### 4. Run app แรกบน iPad

1. ต่อ iPad กับ Mac แล้วเลือก iPad เป็น run destination ด้านบนของ Xcode
2. เลือก Personal Team ที่ **Signing & Capabilities**
3. กด ++cmd+r++
4. ครั้งแรกให้ trust developer บน iPad: **Settings › General › VPN & Device Management**

!!! note "ข้อจำกัดของ Personal Team"
    App หมดอายุภายใน 7 วัน และสร้าง App ID ใหม่ได้จำกัดต่อสัปดาห์ ใช้ project เดิมตลอดงาน อย่าสร้าง project ทิ้งบ่อยๆ

!!! failure "Build error: bundle identifier is not available"
    Bundle ID ซ้ำกับ Personal Team ของเพื่อนร่วมทีม ให้ทำตามวิธีที่ระบุใน Team card หรือถาม TA

### 5. Clone repo ของทีม

**Xcode › Integrate › Clone** แล้ววาง URL จาก Team card หรือใช้ Terminal:

```bash
git clone https://github.com/<org>/team-XX.git
```

## Xcode shortcuts ที่ใช้บ่อย

| Shortcut | ใช้ทำอะไร |
|---|---|
| ++cmd+b++ | Build |
| ++cmd+r++ | Run |
| ++cmd+period++ | Stop |
| ++cmd+shift+o++ | Open Quickly (หาไฟล์/symbol) |
| ++cmd+opt+enter++ | เปิด/ปิด Preview |
| ++cmd+opt+c++ | Commit |

## ใช้ project เดียวกันทั้ง Xcode 26 และ 27

ทีมมีทั้ง Xcode 27 บน {{ mac.apple }} และ Xcode 26 บน {{ mac.intel }} จึงต้องทำให้ project build ได้ทั้งสองเวอร์ชัน

- Deployment target คือ **iOS 26**
- ถ้า Xcode 27 ถามให้ update project format หรือ recommended settings ให้กด **ไม่** 
- Code ที่ใช้ API ของ iOS 27 ต้องครอบไว้แบบนี้:

```swift
#if compiler(>=6.4)   // Swift 6.4 มากับ Xcode 27
if #available(iOS 27, *) {
    // API ใหม่ของ iOS 27
}
#endif
```

!!! intel "{{ mac.intel }} · Xcode 26"
    Simulator บน {{ mac.intel }} ไม่รองรับ Apple Intelligence
