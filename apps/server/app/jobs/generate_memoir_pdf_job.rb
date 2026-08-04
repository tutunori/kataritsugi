# frozen_string_literal: true

# 収集文書から回顧録 PDF を生成（STEP A は簡易テキスト PDF）
class GenerateMemoirPdfJob < ApplicationJob
  queue_as :default

  def perform(memoir_id)
    memoir = Memoir.find(memoir_id)
    memoir.update!(status: "generating")

    texts = memoir.user.recording_sessions.includes(:transcript).filter_map do |s|
      s.transcript&.corrected_text.presence || s.transcript&.raw_text.presence
    end
    body = texts.presence&.join("\n\n") || "（まだ文字起こしがありません）"
    title = memoir.title.presence || "回顧録"
    memoir.update!(title: title, body: body)

    pdf_bytes = minimal_pdf_bytes("#{title}\n\n#{body}")
    memoir.pdf.attach(
      io: StringIO.new(pdf_bytes),
      filename: "memoir-#{memoir.id}.pdf",
      content_type: "application/pdf"
    )
    memoir.update!(status: "ready")
  rescue StandardError => e
    memoir&.update(status: "failed")
    raise e
  end

  private

  # 依存 gem なしの最小 PDF（プレーンテキスト 1 ページ相当）
  def minimal_pdf_bytes(text)
    safe = text.to_s.encode("ASCII", invalid: :replace, undef: :replace, replace: "?")[0, 800]
    content = "BT /F1 12 Tf 50 750 Td (#{escape_pdf(safe)}) Tj ET"
    <<~PDF
      %PDF-1.4
      1 0 obj<< /Type /Catalog /Pages 2 0 R >>endobj
      2 0 obj<< /Type /Pages /Kids [3 0 R] /Count 1 >>endobj
      3 0 obj<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R /Resources<< /Font<< /F1 5 0 R >> >> >>endobj
      4 0 obj<< /Length #{content.bytesize} >>stream
      #{content}
      endstream
      endobj
      5 0 obj<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>endobj
      xref
      0 6
      0000000000 65535 f 
      0000000009 00000 n 
      0000000058 00000 n 
      0000000115 00000 n 
      0000000266 00000 n 
      0000000000 00000 n 
      trailer<< /Size 6 /Root 1 0 R >>
      startxref
      0
      %%EOF
    PDF
  end

  def escape_pdf(str)
    str.gsub("\\", "\\\\").gsub("(", "\\(").gsub(")", "\\)").gsub("\n", ") Tj T* (")
  end
end
