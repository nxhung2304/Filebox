# Filebox — macOS file manager

Filebox là app quản lý file cho macOS, thay thế Finder trong công việc hằng ngày của một developer. Nhẹ, điều khiển tốt bằng bàn phím, có các tính năng dành cho dev (copy đường dẫn, terminal, editor, agent AI).

Tài liệu đi kèm, đọc trước khi code:
- `specs/SPEC.md`: tính năng, các giai đoạn, tiêu chí hoàn thành.
- `specs/DESIGN.md`: bố cục, kích thước, màu, typography, trạng thái UI.
- `specs/design/project/*.dc.html`: mockup HTML tham khảo (canvas: https://claude.ai/artifact/1UtnWqUXkYxehzdcRPzWHG). Khi làm UI, xem mockup này và so sánh với kết quả.

## Công nghệ

- Swift 6 (strict concurrency ở mức `complete` nếu không gây vướng, nếu không thì `targeted`), SwiftUI cho bố cục, AppKit khi SwiftUI không đủ (bảng file, kéo thả, Quick Look, menu chuột phải).
- macOS 14 Sonoma trở lên.
- Project sinh bằng **XcodeGen** từ `project.yml`. Không sửa tay file `.xcodeproj`.
- Không dùng thư viện bên thứ ba, trừ khi SPEC nói rõ. Nếu thật sự cần, hỏi trước.
- **Không bật App Sandbox.** App dùng cá nhân, cần truy cập toàn bộ ổ đĩa. Không phân phối qua App Store.

## Lệnh

```bash
brew install xcodegen                     # một lần
xcodegen generate                         # sau khi thêm/xoá file hoặc sửa project.yml
xcodebuild -project Filebox.xcodeproj -scheme Filebox -configuration Debug -derivedDataPath .build build
xcodebuild -project Filebox.xcodeproj -scheme Filebox -derivedDataPath .build test
open .build/Build/Products/Debug/Filebox.app
```

Chụp màn hình để tự kiểm tra UI (sau khi app đã mở khoảng 2 giây):

```bash
screencapture -x -o /tmp/filebox-shot.png
```

Rồi xem `/tmp/filebox-shot.png` và so sánh với mockup trong `specs/design/`. Nếu bị chặn quyền ghi màn hình, báo người dùng cấp quyền Screen Recording cho terminal.

## Cấu trúc thư mục

```
Filebox/
  App/            FileboxApp.swift, AppState.swift, Commands.swift (menu + phím tắt)
  Models/         FileItem, Tab, PanelState, FavoriteGroup, Settings
  Services/       FileSystemService, FileOperationService, DirectoryWatcher,
                  SearchService, SpotlightService, RecentsService, FavoritesStore,
                  TerminalLauncher, EditorLauncher, PreviewService
  Views/
    Window/       MainWindow, Toolbar, Breadcrumb, StatusBar
    Sidebar/      SidebarView, FavoriteGroupView, FavoriteRow, LocationsSection
    Browser/      PanelView, TabBar, FileTableView (NSTableView), FileRowCell
    Preview/      PreviewPane, CodePreview, InfoList
    Search/       SearchField, CommandPalette
  Resources/      Assets.xcassets
FileboxTests/     test cho Services
specs/            SPEC.md, DESIGN.md, DECISIONS.md, design/project/ (mockup)
project.yml
```

## Quy tắc bắt buộc

**An toàn dữ liệu (quan trọng nhất):**
- Xoá luôn đi qua Thùng rác: `FileManager.trashItem`. Không bao giờ xoá vĩnh viễn trong code app.
- Copy/move trùng tên: hỏi người dùng (Thay thế / Giữ cả hai / Bỏ qua). Không ghi đè im lặng.
- Mọi thao tác file chạy ngoài main thread, có thể huỷ, báo lỗi rõ ràng cho từng file.
- Test cho thao tác file chỉ chạy trên thư mục tạm (`FileManager.default.temporaryDirectory`), không bao giờ đụng tới thư mục người dùng.

**Hiệu năng:**
- Đọc thư mục bất đồng bộ. Thư mục 20.000 file phải mở dưới 1 giây và cuộn mượt.
- Bảng file dùng `NSTableView` (bọc qua `NSViewRepresentable`), không dùng SwiftUI `List` cho bảng chính.
- Tính kích thước thư mục, icon: lazy và có cache, không chặn UI.

**Code:**
- Services không import SwiftUI. Views không gọi `FileManager` trực tiếp.
- State dùng `@Observable` (Observation framework).
- Chuỗi giao diện bằng tiếng Anh, đúng như `DESIGN.md`.
- Màu và font theo `DESIGN.md`: dùng màu ngữ nghĩa của hệ thống để Dark Mode tự hoạt động.

## Cách làm việc

1. Làm theo thứ tự giai đoạn trong `SPEC.md`. Mỗi giai đoạn: lên kế hoạch ngắn, code, build, chạy test, chụp màn hình kiểm tra UI.
2. Build phải sạch lỗi và warning trước khi coi một bước là xong.
3. Commit Git sau mỗi giai đoạn (hoặc mỗi tính năng lớn), message dạng `P3: copy/move với xử lý trùng tên`.
4. Đánh dấu tiêu chí đã đạt trong `SPEC.md` (`- [x]`).
5. Những gì không tự kiểm tra được (kéo thả sang app khác, cảm giác bàn phím, quyền hệ thống): liệt kê ở cuối mỗi giai đoạn để người dùng thử tay.
6. Khi SPEC không rõ: chọn cách đơn giản, an toàn nhất và ghi giả định vào `specs/DECISIONS.md`.
