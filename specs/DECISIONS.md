# Quyết định và giả định

## P0

- `Filebox.xcodeproj` không commit (sinh lại bằng `xcodegen generate`); `.build/` bị bỏ qua.
- Swift 6 language mode, `SWIFT_STRICT_CONCURRENCY = complete`.
- Màu nhóm đặt trong `Assets.xcassets/GroupColors` (Any / Dark); bản Dark sáng hơn 15% (pha 15% về phía trắng).
- Bố cục dùng `HSplitView` (sidebar · vùng duyệt · xem trước) + status bar trải hết chiều ngang; toolbar là toolbar SwiftUI kiểu `.unified`.
- Dữ liệu giả nằm trong `App/SampleData.swift`, sẽ thay bằng dữ liệu thật từ P1 trở đi.
