// โค้ดในไฟล์นี้มาจากหน้า Core ML หัวข้อ "Model ในระบบ: ข้อความบวกหรือลบ"
// ใช้ model ที่ Apple ใส่ไว้ใน iOS แล้ว ไม่ต้องดาวน์โหลดหรือ train ใช้ได้กับภาษาอังกฤษ
import NaturalLanguage

/// คะแนนความรู้สึกของข้อความ -1 (ลบมาก) ถึง 1 (บวกมาก) ได้ nil ถ้าวิเคราะห์ไม่ได้
func sentimentScore(of text: String) -> Double? {
    let tagger = NLTagger(tagSchemes: [.sentimentScore])
    tagger.string = text
    let (tag, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
    return tag.flatMap { Double($0.rawValue) }
}
