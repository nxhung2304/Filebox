# Filebox — Đặc tả giao diện

Mockup tham khảo: `specs/design/project/Main.dc.html` (canvas: https://claude.ai/artifact/1UtnWqUXkYxehzdcRPzWHG). Khi mockup và tài liệu này khác nhau, **tài liệu này đúng**.

## Nguyên tắc

- Trông và cảm giác như app native macOS: icon hệ thống, SF Symbols, font hệ thống, màu ngữ nghĩa.
- Mật độ cao hơn Finder một chút: thấy được nhiều file hơn.
- Bàn phím là trên hết: luôn thấy rõ đang focus ở đâu.
- Màu chỉ dùng để mang ý nghĩa: lựa chọn, màu nhóm.

## Bố cục cửa sổ

```
┌───────────────────────────────────────────────────────────────────────┐
│ ●●●  ‹ ›  ~ › Projects › ngan-app › Sources            ☰▥▦  ▯▯  [🔍 Search…  ⌘K] │  Toolbar 48
├────────────┬──────────────────────────────────────────┬───────────────┤
│ FAVORITES  │ [Sources] [Downloads] [blog / posts] [+] │ icon  name    │  Tab bar 34
│ ◷ Recents  ├──────────────────────────────────────────┤ kind · size   │
│ ▭ Desktop  │ Name ▾     Date Modified  Size  Kind     │ ┌───────────┐ │
│ ▭ Downloads│ ▭ Views    Today…          —   Folder    │ │ code      │ │
│ ▭ Documents│ ▭ Models   …                             │ │ preview   │ │
│ ▾ ● Dev  3 │ ▯ AppState.swift  …   3.1 KB Swift      │ └───────────┘ │
│   ▭ ngan… >_│ ▯ FileBrowserView.swift (selected)      │ Modified      │
│   ▭ blog   │ …                                        │ Path          │
│ › ● Clients 2│                                        │               │
│ ▾ ● Personal│                                         │ [Open in Editor]│
│ + New Group│                                          │ [Copy] [Term] │
│ LOCATIONS  │                                          │ [>_ Claude ▾] │
│ ▭ Macintosh HD│                                       │               │
├────────────┴──────────────────────────────────────────┴───────────────┤
│ 12 items, 1 selected · Hidden files: shown   184 GB available │  Status 24
└───────────────────────────────────────────────────────────────────────┘
```

| Vùng | Kích thước |
|---|---|
| Cửa sổ mặc định / tối thiểu | 1280×800 / 860×520 |
| Toolbar | cao 48 px, dùng `NSToolbar` unified, có nút cửa sổ hệ thống |
| Sidebar | rộng 220 px (kéo được 180–320), có thể ẩn (⌘⌥S) |
| Tab bar | cao 34 px |
| Hàng trong bảng | 28 px (Gọn 24, Rộng 32) |
| Header bảng | 26 px |
| Panel xem trước | rộng 320 px (kéo được 260–480) |
| Status bar | cao 24 px |
| Padding ngang trong bảng | 16 px |
| Bo góc nút / hàng sidebar | 6 px; ô tìm kiếm 7 px; khung code 8 px |

Hai panel: vùng duyệt chia đôi theo chiều ngang bằng `NSSplitView`, mỗi panel có thanh tab riêng.

## Màu

Dùng màu ngữ nghĩa của hệ thống; các mã hex là giá trị light mode trong mockup để tham chiếu.

| Vai trò | Màu hệ thống | Hex (light, tham chiếu) |
|---|---|---|
| Nền vùng duyệt | `controlBackgroundColor` | #FFFFFF |
| Hàng xen kẽ | `alternatingContentBackgroundColors` | #F6F6F8 |
| Nền sidebar, toolbar, status bar | vật liệu `.sidebar` / `windowBackgroundColor` | #F4F4F6 |
| Nền panel xem trước | `underPageBackgroundColor` | #FAFAFB |
| Chữ chính | `labelColor` | #1D1D1F |
| Chữ phụ (ngày, kích thước, tiêu đề mục) | `secondaryLabelColor` | #6B6B70 |
| Đường kẻ | `separatorColor` | #DCDCE0 |
| Màu nhấn, hàng đang chọn | `controlAccentColor` (theo cài đặt hệ thống) | #0B63CE |
| Chữ trên hàng đang chọn | `alternateSelectedControlTextColor` | #FFFFFF |
| Mục sidebar đang mở | `selectedContentBackgroundColor` khi focus, `unemphasizedSelectedContentBackgroundColor` khi không | #E2E2E7 |
| File ẩn | `secondaryLabelColor` | #6B6B70 |

**Bảng màu nhóm** (8 màu cố định): Blue #2F6FB0, Orange #C2570C, Purple #7A3FC2, Green #2E7D4F, Red #C0392B, Pink #C2417A, Teal #0F7C86, Gray #6B6B70. Ở Dark Mode dùng phiên bản sáng hơn khoảng 15%.

## Typography

| Thành phần | Font |
|---|---|
| Mặc định (tên file, nút, sidebar) | System 13 regular |
| Tên nhóm sidebar | System 12 semibold |
| Tiêu đề mục sidebar ("Favorites", "Locations"), header bảng | System 11 semibold, `secondaryLabelColor` |
| Ngày, kích thước, loại | System 13, `secondaryLabelColor`; kích thước dùng chữ số tabular, căn phải |
| Tên file trong preview | System 14 semibold |
| Đường dẫn, phím tắt, code | SF Mono 11–11.5 |
| Status bar | System 11 |

## Thành phần

### Toolbar
Thứ tự từ trái sang: nút back/forward (forward mờ khi không dùng được) · breadcrumb (đoạn cuối đậm, các đoạn trước màu phụ, phân cách `›`) · nhóm nút kiểu xem (List / Columns / Icons, dạng segmented) · nút chia đôi · ô tìm kiếm (rộng 260 px, icon kính lúp, placeholder "Search in <tên thư mục>", gợi ý `⌘K` ở cuối). Toolbar xuống dòng thay vì cắt khi cửa sổ hẹp.

### Sidebar
- Mục "Favorites": tiêu đề mục, rồi các mục không nhóm (Recents dùng SF Symbol `clock`, thư mục dùng `folder`), rồi các nhóm, cuối cùng là nút "+ New Group" (màu phụ, cỡ 12).
- Hàng nhóm: mũi tên (`chevron.right`, xoay 90° khi mở, có animation 0.15 s) · chấm màu 8 px · tên nhóm · số mục (màu phụ) · tay cầm kéo sáu chấm (chỉ hiện khi rê chuột).
- Hàng mục trong nhóm: thụt vào 10 px, icon `folder` mang màu nhóm, tên cắt bằng dấu "…" ở cuối.
- Mục đang duyệt: nền tô. Rê chuột lên một hàng thư mục hoặc ở hàng đang chọn: hiện nút vuông 26×24 px bên phải, icon `apple.terminal` (hoặc `chevron.right` + gạch dưới), tooltip "Open <agent> Here (⌘⇧A)".
- Kéo thả: nhóm đích có nền xanh nhạt và viền nét đứt 1.5 px màu nhấn; khi sắp thứ tự, hiện vạch ngang 2 px màu nhấn ở vị trí chèn. Thả xong, nhóm đích tự mở.
- Mục "Locations": ổ đĩa (`internaldrive`, kèm "184 GB available" màu phụ bên phải), iCloud Drive (`icloud`), ổ ngoài kèm nút eject khi rê chuột.

### Thanh tab
Tab rộng tối đa 200 px, co lại khi nhiều tab. Tab active: nền trắng (nền vùng duyệt), chữ semibold. Tab khác: nền như tab bar (#ECECEF), chữ màu phụ. Nút đóng `×` hiện khi rê chuột. Nút `+` ở cuối. Panel không focus: tab active dùng chữ thường thay vì semibold. Ở chế độ hai panel, tab active của panel đang focus có thêm vạch màu nhấn 2 px ở cạnh trên.

### Bảng file
- Cột: Tên (3 phần) · Ngày sửa (1.6) · Kích thước (1, căn phải) · Loại (1). Cột kéo được độ rộng, thứ tự cột cố định.
- Icon file/thư mục 16 px lấy từ `NSWorkspace.icon(forFile:)`.
- Ngày: "Today 09:40", "Yesterday 21:12", trong năm nay "Oct 14", năm khác "Oct 14, 2025".
- Kích thước: "3.1 KB", "96 bytes", thư mục "—" (hoặc kích thước đã tính, màu phụ).
- Hàng đang chọn: nền màu nhấn, toàn bộ chữ và icon thư mục màu trắng. Khi bảng mất focus: nền xám nhạt (`unemphasizedSelectedContentBackgroundColor`), chữ giữ màu thường.
- Hàng có focus bàn phím nhưng chưa chọn (khi đa chọn): viền trong 1 px màu nhấn.
- Đổi tên tại chỗ: ô nhập thay cho tên, cùng cỡ chữ, viền màu nhấn.
- Thư mục trống: chữ giữa vùng "Empty Folder" màu phụ.

### Panel xem trước
Từ trên xuống, khoảng cách 14 px: dòng tiêu đề (icon 32 px, tên, "loại · kích thước") · khung xem trước (nền trắng, viền `separatorColor`, bo 8 px, padding 12 px, cao tối đa 340 px, code mono 11.5 px, line-height 1.55) · danh sách thông tin hai cột (nhãn màu phụ: Modified, Path) · hàng nút (xuống dòng khi hẹp).

Màu cú pháp (light / dark): từ khoá #A0279E / #FF7AB2, kiểu và tên type #1F5F99 / #6BDFFF, chuỗi #B0361A / #FF8170, số #1C00CF / #D9C97C, comment #6B6B70 nghiêng / #7F8C98.

Khi không có bản xem trước: khung viền nét đứt, chữ giữa màu phụ, ví dụ "Folder · 8 items" hoặc "Press Space to Quick Look".

Nút: "Open in Editor" là nút chính (nền màu nhấn, chữ trắng); "Copy Path", "Open in Terminal" là nút phụ (nền trắng, viền); nút agent dạng split: icon `>_` + tên agent mặc định + `▾` mở menu chọn agent.

### Status bar
Trái sang phải, cách nhau 18 px: "12 items, 1 selected" · "Hidden files: shown (⌘⇧.)" · đẩy sang phải: dung lượng trống. Khi đang có thao tác file: thay phần giữa bằng "Copying 3/12 · 45 MB of 120 MB", thanh tiến trình mảnh 120 px và nút huỷ. Ở chế độ hai panel, phần giữa hiện gợi ý "F5 Copy to right pane · F6 Move to right pane" (theo hướng panel kia). Khi đang tìm kiếm: "5 results in “filebox” and subfolders, 1 selected", kèm "Skipping .gitignore patterns" nếu đang bỏ qua mẫu `.gitignore`.

### Tìm kiếm
Khi ô tìm kiếm có chữ: dưới toolbar hiện một dải cao 32 px với chip phạm vi ("This Folder" / "This Mac"), công tắc "Include Subfolders", ô "Contents" (chỉ hiện khi có `rg`), chip loại ("Any Kind" / Folders / Images / Documents / Code) và chip thời gian ("Any Time" / Today / Last 7 Days / Last 30 Days); mỗi nhóm chip chọn một, "Any …" là bỏ lọc. Ô tìm kiếm đang có chữ: viền màu nhấn 2 px và nút xoá. Bảng hiển thị kết quả, thêm cột "Location" (đường dẫn tương đối, màu phụ). Phần khớp trong tên được tô đậm.

### Command palette (⌘K)
Hộp nổi giữa trên cửa sổ, rộng 560 px, bo 10 px, bóng đổ hệ thống. Ô nhập ở trên, danh sách tối đa 10 kết quả, mỗi dòng: icon · tên lệnh · phím tắt (mono, màu phụ) bên phải; mục không có phím tắt hiện nhãn phụ thay thế ("Favorite", "Recent tab"). Dòng cuối hộp, cao 28 px, gợi ý phím: "↑↓ Move · ↩ Run · esc Close". Esc đóng.

### Hộp thoại trùng tên
Sheet gắn vào cửa sổ, rộng 480 px. Tiêu đề: "An item named “<tên>” already exists in “<thư mục>”." Dưới đó là khung so sánh hai dòng (Existing / Copying hoặc Moving): tên, kích thước, ngày sửa. Ô "Apply to All" kèm số xung đột còn lại ("(4 more conflicts)"). Nút, trái sang phải: "Stop" (huỷ cả thao tác, tách sang trái) · "Skip" · "Replace" · "Keep Both". Nút mặc định (Enter) là **Keep Both** để Enter không bao giờ ghi đè.

### Settings (⌘,)
Cửa sổ 720×560, một trang, ba nhóm có tiêu đề mục: **General** (Open at launch + nút "Choose…", Show hidden files by default, Row height dạng segmented Compact / Medium / Large) · **Tools** (Terminal, Editor: popup chọn app) · **AI Agents** (bảng Name / Command / Default: tay cầm kéo để sắp xếp, radio chọn agent mặc định, nút + / −). Agent không có trong PATH: nhãn cảnh báo "Not found in PATH" màu cam cạnh dòng đó.

## Trạng thái và phản hồi

- Đang tải thư mục lâu hơn 150 ms: spinner nhỏ ở breadcrumb, không xoá danh sách cũ cho tới khi có dữ liệu mới.
- Lỗi quyền: thay bảng bằng icon khoá, thông báo "You don't have permission to access this folder", dòng hướng dẫn màu phụ "Give Filebox Full Disk Access in System Settings, then reopen this folder." và nút chính "Open Full Disk Access Settings".
- Thư mục Yêu thích không còn tồn tại: hàng mờ, icon `exclamationmark.triangle` màu cam.
- Hoàn tác xong: thông báo nhỏ trong status bar 3 giây ("Restored 2 items").

## Dark Mode
Tất cả màu ở trên lấy từ màu ngữ nghĩa nên tự đổi. Riêng màu nhóm và màu cú pháp phải có bộ màu dark riêng trong Asset Catalog (Any / Dark). Chụp màn hình cả hai chế độ để kiểm tra.

## Khả năng tiếp cận
Mọi nút chỉ có icon phải có `accessibilityLabel` tiếng Anh. Thứ tự Tab hợp lý: toolbar → sidebar → panel trái → panel phải → xem trước. Tương phản chữ ≥ 4.5:1 ở cả hai chế độ.
