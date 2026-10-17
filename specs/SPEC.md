# Filebox — Đặc tả tính năng

## Mục tiêu

Một file manager cho macOS dùng hằng ngày thay Finder, tập trung vào: điều khiển bằng bàn phím, tìm kiếm tốt hơn, sidebar có nhóm, và các thao tác cho dev (copy đường dẫn, mở terminal/editor/agent AI).

Ngoài phạm vi bản này: hiển thị trạng thái Git (cột Git, branch, thông tin repo ở status bar), FTP/SFTP/S3, đồng bộ thư mục, đổi tên hàng loạt nâng cao, plugin, phân phối App Store.

## Khái niệm

- **Cửa sổ** gồm: toolbar, sidebar, vùng duyệt (1 hoặc 2 panel), panel xem trước (ẩn/hiện), status bar.
- **Panel** có nhiều **tab**; mỗi tab có thư mục hiện tại, lịch sử back/forward, kiểu sắp xếp, lựa chọn.
- Chỉ một panel **đang focus** tại một thời điểm; mọi lệnh áp dụng cho panel đó.
- **Yêu thích** gồm các mục không thuộc nhóm ở trên cùng và các **nhóm** có tên, màu, có thể thu gọn.

---

## P0 — Khung project

- [x] `project.yml` cho XcodeGen: target app `Filebox` (macOS 14, bundle id `dev.local.filebox`, không sandbox), target test `FileboxTests`.
- [x] App mở một cửa sổ trống với bố cục đúng vùng (toolbar, sidebar, vùng duyệt, preview, status bar) bằng dữ liệu giả.
- [x] Build và test chạy được bằng lệnh trong `CLAUDE.md`.

## P1 — Duyệt thư mục (một panel)

- [ ] `FileSystemService` liệt kê thư mục bất đồng bộ, trả về `FileItem` (url, tên, là thư mục, kích thước, ngày sửa, loại, ẩn hay không, là symlink/alias).
- [ ] Bảng file dạng danh sách với các cột: Name (icon + tên), Date Modified, Size, Kind. Bấm tiêu đề cột để sắp xếp; thư mục luôn đứng trước file.
- [ ] Mở thư mục bằng Enter hoặc double-click; mở file bằng app mặc định (`NSWorkspace.open`).
- [ ] Back/forward (⌘[ và ⌘]), lên thư mục cha (⌘↑).
- [ ] Breadcrumb trong toolbar, mỗi đoạn bấm được.
- [ ] Ô nhập đường dẫn (⌘⇧G) có autocomplete, hỗ trợ `~`.
- [ ] Bật/tắt file ẩn (⌘⇧.). File ẩn hiển thị màu mờ.
- [ ] Gõ chữ khi bảng đang focus thì nhảy tới file có tên bắt đầu bằng chuỗi đó.
- [ ] `DirectoryWatcher` (FSEvents) cập nhật danh sách khi file thay đổi từ bên ngoài, giữ nguyên lựa chọn và vị trí cuộn.
- [ ] Thư mục 20.000 file mở dưới 1 giây, cuộn mượt.

## P2 — Tab và chia đôi

- [ ] Thanh tab trên mỗi panel: ⌘T tab mới (cùng thư mục), ⌘W đóng tab, ⌃Tab / ⌃⇧Tab chuyển tab, ⌘1…⌘9 chọn tab.
- [ ] Nút và phím tắt (⌘\\) bật/tắt chế độ hai panel.
- [ ] Tab (phím) chuyển focus giữa hai panel; panel đang focus có tab active nổi bật hơn.
- [ ] Khôi phục các tab, thư mục và chế độ panel khi mở lại app.

## P3 — Thao tác file

- [ ] Copy (⌘C), Cut (⌘X), Paste (⌘V) giữa các thư mục và các panel. Ở chế độ hai panel: F5 copy sang panel kia, F6 move sang panel kia.
- [ ] Đổi tên tại chỗ (Enter khi đã chọn một file, hoặc F2). Chọn sẵn phần tên, không chọn đuôi file.
- [ ] Xoá vào Thùng rác (⌘⌫), có hoàn tác (⌘Z) đưa file về chỗ cũ.
- [ ] Thư mục mới (⌘⇧N), tên mặc định "untitled folder", vào chế độ đổi tên ngay.
- [ ] Hộp thoại xử lý trùng tên: Replace / Keep Both / Skip, có ô "Apply to All" và nút Stop huỷ cả thao tác. Nút mặc định là Keep Both.
- [ ] Thao tác dài hiển thị tiến trình trong status bar, có nút huỷ. Không chặn UI.
- [ ] Menu chuột phải trên file: Open, Open With…, Quick Look, Copy Path, Rename, Duplicate, Compress, Show in Finder, Move to Trash.
- [ ] Kéo thả file: trong app, giữa hai panel, ra app khác và từ app khác vào. Giữ ⌥ để copy, mặc định move trong cùng ổ.
- [ ] Unit test cho `FileOperationService`: copy, move, rename, trash, trùng tên, huỷ giữa chừng, lỗi quyền.

## P4 — Sidebar

- [ ] **Favorites, phần không nhóm** ở trên cùng: mặc định gồm Recents, Desktop, Downloads, Documents.
- [ ] **Recents**: mở ra một danh sách ảo gồm các file dùng gần nhất, lấy từ Spotlight (`kMDItemLastUsedDate`, 30 ngày, tối đa 200 mục), sắp mới nhất trước.
- [ ] **Nhóm**: tên, màu, số mục, mũi tên thu gọn/mở. Trạng thái thu gọn được lưu lại.
- [ ] Màu nhóm chọn từ bảng cố định 8 màu (xem DESIGN.md). Icon thư mục trong nhóm mang màu của nhóm.
- [ ] Nút "New Group" ở cuối mục Favorites. Double-click tên nhóm để đổi tên. Menu chuột phải trên nhóm: Rename, Change Color, Delete Group (các thư mục bên trong chuyển về phần không nhóm).
- [ ] Kéo thả: kéo thư mục giữa các nhóm, sắp lại thứ tự trong nhóm, kéo cả nhóm để đổi thứ tự nhóm, kéo thư mục từ bảng file hoặc từ Finder vào sidebar để thêm. Vùng thả hiện viền nét đứt; vị trí chèn hiện vạch ngang.
- [ ] Menu chuột phải trên mục: Open in New Tab, Remove from Favorites, Move to Group…
- [ ] Mục trỏ tới thư mục không còn tồn tại: hiển thị mờ với icon cảnh báo, không tự xoá.
- [ ] Lưu toàn bộ Favorites ở `~/Library/Application Support/Filebox/favorites.json` (lưu bằng bookmark data hoặc đường dẫn, kèm id, nhóm, thứ tự, màu, trạng thái thu gọn). Ghi file nguyên tử.
- [ ] **Locations**: các ổ đĩa đã mount (kèm dung lượng trống) và iCloud Drive nếu có. Nút eject cho ổ ngoài.
- [ ] Mục đang được duyệt được tô nền. Khi rê chuột lên một mục thư mục (hoặc mục đang chọn), hiện nút `>_` mở agent AI tại thư mục đó (xem P7).

## P5 — Xem trước

- [ ] Panel xem trước bên phải, bật/tắt bằng ⌘⇧P. Hiển thị cho mục đang chọn: icon, tên, loại, kích thước, ngày sửa, đường dẫn đầy đủ.
- [ ] File code/văn bản (≤ 1 MB): hiển thị 200 dòng đầu với tô màu cú pháp (tự viết highlighter đơn giản theo từ khoá cho Swift, JS/TS, Python, JSON, YAML, Markdown, shell; không cần parser đầy đủ). JSON được format lại.
- [ ] Ảnh, PDF, video: dùng `QLPreviewView`.
- [ ] Thư mục: số mục bên trong và tổng kích thước (tính nền, có thể huỷ).
- [ ] Space mở Quick Look toàn màn hình (`QLPreviewPanel`), mũi tên lên/xuống đổi file khi đang mở.
- [ ] Hàng nút: Open in Editor, Copy Path, Open in Terminal, và nút agent có menu chọn (xem P7).

## P6 — Tìm kiếm

- [ ] Ô tìm kiếm trên toolbar (⌘F) có hai phạm vi, chuyển bằng chip: "This Folder" và "This Mac".
- [ ] "This Folder": lọc tức thì theo tên trong thư mục hiện tại; bật tuỳ chọn "Include Subfolders" thì tìm đệ quy, bỏ qua `.git`, `node_modules`, `.build`, `DerivedData` và các mẫu trong `.gitignore` nếu đang ở trong repo.
- [ ] Khớp kiểu fuzzy (các ký tự xuất hiện theo thứ tự), xếp hạng ưu tiên khớp đầu từ và khớp liên tiếp. Phần khớp được tô đậm.
- [ ] "This Mac": dùng `NSMetadataQuery` (Spotlight), cập nhật kết quả dần.
- [ ] Bộ lọc nhanh: loại file (Folders, Images, Documents, Code), thời gian sửa (Today, Last 7 Days, Last 30 Days).
- [ ] Tìm theo nội dung (tuỳ chọn): nếu có `rg` (ripgrep) trong PATH thì dùng, hiện dòng khớp; Enter mở file tại dòng đó trong editor. Không có `rg` thì ẩn tuỳ chọn này.
- [ ] Kết quả hiển thị trong bảng file bình thường, có thêm cột "Location".
- [ ] Command palette (⌘K): tìm và chạy mọi lệnh của app, nhảy tới thư mục Favorites, mở tab gần đây.

## P7 — Tính năng cho dev

- [ ] **Copy Path** (⌘⌥C): đường dẫn tuyệt đối. Menu con: đường dẫn tương đối so với gốc repo, chỉ tên file, đường dẫn dạng `~`.
- [ ] **Open in Terminal** (⌘⌥T): mở thư mục đang chọn (hoặc thư mục hiện tại) trong terminal cấu hình được: Terminal, iTerm2, Ghostty, Warp.
- [ ] **Open in Editor** (⌘⌥E): mở file/thư mục trong editor cấu hình được (VS Code, Cursor, Zed, Xcode…), mặc định VS Code. Kết quả tìm theo nội dung mở đúng dòng.
- [ ] **Agent AI** (⌘⇧A): mở terminal tại thư mục và chạy lệnh của agent mặc định. Cấu hình là danh sách `{tên, lệnh}`, mặc định: Claude Code → `claude`, Codex → `codex`, Gemini CLI → `gemini`. Nút trong preview hiện tên agent mặc định kèm mũi tên chọn agent khác. Nếu agent chưa cài (không có trong PATH của login shell), báo lỗi rõ và gợi ý cách cài.
- [ ] TerminalLauncher dùng AppleScript/`open -a` an toàn: đường dẫn luôn được escape, không ghép chuỗi lệnh từ tên file chưa escape.

## P8 — Hoàn thiện

- [ ] Dark Mode đúng hoàn toàn (kiểm tra từng màn hình).
- [ ] Màn hình Settings (⌘,): thư mục mở khi khởi động, terminal, editor, danh sách agent, hiện file ẩn mặc định, độ cao hàng (Compact / Medium / Large).
- [ ] Kiểu xem Columns và Icons (có thể làm sau cùng; nếu chưa làm thì nút hiển thị nhưng disabled).
- [ ] Hướng dẫn cấp Full Disk Access khi gặp lỗi quyền lần đầu (nút mở thẳng System Settings đúng mục).
- [ ] Không có crash khi: ổ ngoài bị rút, thư mục bị xoá khi đang mở, file không có quyền đọc, tên file có ký tự Unicode/emoji/dấu tiếng Việt dạng NFD.

---

## Phím tắt tổng hợp

| Phím | Lệnh |
|---|---|
| Enter / ⌘↓ | Open |
| ⌘↑ | Enclosing Folder |
| ⌘[ / ⌘] | Back / Forward |
| ⌘⇧G | Go to Folder |
| ⌘⇧. | Show/Hide Hidden Files |
| Space | Quick Look |
| ⌘T / ⌘W | New Tab / Close Tab |
| ⌃Tab | Next Tab |
| ⌘\\ | Toggle Dual Pane |
| Tab | Switch Pane |
| ⌘C / ⌘X / ⌘V | Copy / Cut / Paste |
| F5 / F6 | Copy / Move to Other Pane |
| F2 | Rename |
| ⌘⌫ | Move to Trash |
| ⌘Z | Undo |
| ⌘⇧N | New Folder |
| ⌘F | Search |
| ⌘K | Command palette |
| ⌘⇧P | Show/Hide Preview |
| ⌘⌥C | Copy Path |
| ⌘⌥T | Open in Terminal |
| ⌘⌥E | Open in Editor |
| ⌘⇧A | Open AI Agent Here |

Nếu một phím tắt xung đột với hệ thống, chọn phím khác, ghi vào `specs/DECISIONS.md` và cập nhật bảng này.
