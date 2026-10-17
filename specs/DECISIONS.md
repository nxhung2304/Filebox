# Quyết định và giả định

## P0

- `Filebox.xcodeproj` không commit (sinh lại bằng `xcodegen generate`); `.build/` bị bỏ qua.
- Swift 6 language mode, `SWIFT_STRICT_CONCURRENCY = complete`.
- Màu nhóm đặt trong `Assets.xcassets/GroupColors` (Any / Dark); bản Dark sáng hơn 15% (pha 15% về phía trắng).
- Bố cục dùng `HSplitView` (sidebar · vùng duyệt · xem trước) + status bar trải hết chiều ngang; toolbar là toolbar SwiftUI kiểu `.unified`.
- Dữ liệu giả nằm trong `App/SampleData.swift`, sẽ thay bằng dữ liệu thật từ P1 trở đi.

## P1

- Cửa sổ chính dùng `Window` (một cửa sổ) thay vì `WindowGroup`, vì menu lệnh làm việc trên một `AppState` duy nhất.
- Mở nhiều mục cùng lúc: chỉ vào thư mục khi chọn đúng một thư mục; các trường hợp khác mở các file bằng app mặc định, bỏ qua thư mục.
- Package (`.app`, `.xcodeproj`…) được coi là file: mở bằng app mặc định, cột Size hiện "—".
- Alias được phân giải lúc mở; symlink tới thư mục được duyệt như thư mục.
- Lên thư mục cha (⌘↑) hoặc Back về thư mục cha thì chọn sẵn thư mục vừa rời.
- Kích thước hiển thị theo cơ số 1000 như Finder, một chữ số thập phân khi dưới 100 ("3.1 KB", "184 GB").
- `DirectoryWatcher` chỉ theo dõi thư mục của tab đang active ở panel đang focus; thay đổi trong thư mục con bị bỏ qua.
- Lỗi đọc thư mục: hiện thông báo quyền / không tồn tại trong bảng. Nút mở Full Disk Access để P8.
- Panel xem trước tạm bỏ khung code giả; nội dung xem trước làm ở P5.
- Icon app lấy từ `specs/filebox-icon-1024.png`, sinh `AppIcon.appiconset` bằng `sips`.

## Điều chỉnh theo yêu cầu người dùng (sau P1)

- "Hidden files: shown/hidden" ở status bar là nút bấm để bật/tắt; bỏ chữ "(⌘⇧.)", phím tắt vẫn giữ trong menu View và hiện ở tooltip.
- Thanh tab chỉ hiện khi panel có từ 2 tab.
- Tiêu đề cửa sổ là tên thư mục hiện tại (không còn "Filebox").
- Placeholder ô tìm kiếm là "Search".
- Bố cục kiểu Finder: `NavigationSplitView`, sidebar cao hết cửa sổ (nền vật liệu sidebar), toolbar và status bar chỉ nằm ở vùng bên phải sidebar.
- Panel xem trước mặc định rộng 260 px (kéo được 220–480). Khi chưa chọn gì, hiện thông tin thư mục hiện tại (tên, "Folder · N items", đường dẫn) thay vì để trống.
- Toolbar kiểu Finder: back/forward bên trái, ngay sau đó là tiêu đề cửa sổ native = tên thư mục hiện tại, các nút khác dồn sang phải. Breadcrumb (SPEC P1) chuyển thành menu tiêu đề (`toolbarTitleMenu`): liệt kê thư mục hiện tại và các thư mục cha tới `/`, bấm để nhảy tới.
- Panel xem trước là inspector (`.inspector`): cột riêng cao hết cửa sổ, nền mặc định của inspector, toolbar chỉ nằm trên vùng duyệt; nút ẩn/hiện ở toolbar (⌘⇧P).
- Ô tìm kiếm dùng `.searchable` native; bỏ gợi ý ⌘K trong ô.
- Nút trong preview: cỡ thường; Copy Path và Open in Terminal chỉ có icon + tooltip.
- Nút "Open in Editor": khi cửa sổ không active chuyển sang kiểu `.bordered`, vì `.borderedProminent` trên macOS 26 ở light mode vẽ chữ trắng trên nền gần trắng.
- Mặc định ẩn file ẩn khi mở app (giống Finder); tuỳ chọn trong Settings ở P8.
