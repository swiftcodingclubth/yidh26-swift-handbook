# Swift Workshop Handbook

ยินดีต้อนรับสู่ Hackathon! Handbook นี้รวมขั้นตอนและ code snippets ของทั้ง 5 workshop ไว้ในที่เดียว เปิดไว้ข้าง Xcode แล้วทำตามได้เลย

## Workshops

!!! tip "เลือก workshop ช่วงบ่าย"
    เลือกตาม idea ของทีม ถ้าทีมแยกกันเข้า ให้คนที่เข้า **Room A** ถือ {{ mac.apple }} ไปด้วย

<div class="grid cards" markdown>

-   **1. Code-along: Build your first app with coding agents**

    ---

    Git, Xcode agents, OpenCode และการเขียน prompt · บังคับทุกคน

    [:octicons-arrow-right-24: เริ่ม Workshop 1](workshop-1/index.md)

-   **2. Bring intelligence to your app with Foundation Models and on-prem AI**

    ---

    AFM 3, Private Cloud Compute และ AI cluster ของงาน

    [:octicons-arrow-right-24: เริ่ม Workshop 2](workshop-2/index.md)

-   **3. Build sensor-aware intelligence with Core AI and Create ML**

    ---

    Train model จาก motion, LiDAR และเสียง แล้ว run บน device

    [:octicons-arrow-right-24: เริ่ม Workshop 3](workshop-3/index.md)

-   **4. Extend your app across the system with App Intents**

    ---

    Action เดียว ใช้ได้ทั้ง Shortcuts, Spotlight, Siri, widget และ Control Center

    [:octicons-arrow-right-24: เริ่ม Workshop 4](workshop-4/index.md)

-   **5. Give your app sight with Vision and VisionKit**

    ---

    Scan เอกสาร อ่านข้อความ และ track มือ/ร่างกายจากกล้อง

    [:octicons-arrow-right-24: เริ่ม Workshop 5](workshop-5/index.md)

</div>

## อุปกรณ์ของแต่ละทีม

MacBook Pro M chip ×1 · MacBook Pro Intel ×2 · iPad M chip ×3 → [ดูรายละเอียด](workshop-1/hardware.md)

## กฎ 3 ข้อ

1. **Commit ก่อนให้ agent แก้โค้ดทุกครั้ง** — ถ้าพังจะย้อนกลับได้ทันที
2. **ห้ามใส่ API key หรือข้อมูลส่วนตัว** ใน prompt และใน commit
3. **ข้อมูลสุขภาพใช้ synthetic data เท่านั้น** ห้ามใช้ข้อมูลผู้ป่วยจริง (PDPA)
