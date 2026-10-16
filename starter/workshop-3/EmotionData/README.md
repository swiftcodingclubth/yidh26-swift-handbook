# EmotionData: ข้อมูลสำหรับ train Text Classifier

ข้อมูลสำหรับ train model จำแนกอารมณ์จากข้อความใน Create ML ตามหน้า Create ML ของ handbook ข้อความเป็นภาษาอังกฤษทั้งหมด

| ไฟล์ | จำนวน | ใช้ใน Create ML ช่อง |
|---|---|---|
| `emotion6_train.csv` | 18,000 ประโยค | **Training Data** |
| `emotion6_test.csv` | 2,000 ประโยค | **Testing Data** |
| `emotion6_mytest.csv` | 30 ประโยค | **+ New Test** ในแท็บ Evaluation (ประโยคที่แต่งขึ้นเอง ไม่อยู่ใน dataset) |

ทุกไฟล์มี 2 column คือ `text` และ `label` ซึ่งเป็นชื่อที่ Text Classifier ของ Create ML ต้องการ ถ้าใช้ชื่ออื่นจะขึ้น error "missing required field label"

## 6 อารมณ์

| label | จำนวนใน train |
|---|---|
| joy | 6,066 |
| sadness | 5,216 |
| anger | 2,434 |
| fear | 2,149 |
| love | 1,482 |
| surprise | 653 |

ไม่มี `neutral` model จะตอบอารมณ์ใดอารมณ์หนึ่งเสมอ ให้ใช้ความมั่นใจต่ำเป็นสัญญาณว่า "ไม่แน่ใจ" แบบในหน้า "วันนี้รู้สึกอย่างไร" ของ starter

## ขั้นตอนใน Create ML

1. **New Project → Text Classification**
2. **Training Data:** `emotion6_train.csv` · **Validation Data:** Automatic · **Testing Data:** `emotion6_test.csv`
3. **Algorithm:** Maximum Entropy (train ไม่กี่วินาที)
4. กด **Train** ควรได้ Testing ประมาณ 88%
5. **Output → Get** ตั้งชื่อ `EmotionClassifier.mlmodel` แล้วลากไปแทนไฟล์ใน `Workshop3Starter/MLParts/Models/`

## ที่มา

[Emotions dataset for NLP](https://www.kaggle.com/datasets/praveengovi/emotions-dataset-for-nlp) บน Kaggle แปลงจากไฟล์ `train.txt` + `val.txt` และ `test.txt` (รูปแบบ `text;label`) เป็น CSV ดูเงื่อนไขการใช้งานที่หน้า Kaggle ก่อนนำไปใช้นอก workshop
