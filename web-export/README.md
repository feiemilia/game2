# 本機 Web 版

此資料夾由 Godot 4.7.2 的 `Web` Release preset 輸出，對應兩關生活理財學習遊戲。網頁使用全螢幕沉浸式畫布，載入頁採深色背景、中央「微光理財屋」標題和底部進度條，參考 https://victor28825252-debug.github.io/Game1/little-finance-nightmares/docs/ 的 Godot Web 版呈現方式。獨立 Blender 原始檔與便攜 Blender 程式不會打入遊戲包，因目前場景未載入它們。

請用本機 HTTP 伺服器開啟，不要直接雙擊 `index.html`。在專案根目錄執行：

```powershell
powershell -ExecutionPolicy Bypass -File .\Run_Web_Preview.ps1
```

腳本會從 `http://127.0.0.1:8000` 提供檔案，並嘗試開啟預設瀏覽器。再次匯出可執行專案根目錄的 `Export_Web.ps1`。關閉伺服器可在 PowerShell 視窗按 Ctrl+C。

Godot Web 輸出需搭配本機或正式網站的 HTTP(S) 伺服器。此版本使用無執行緒範本，不需跨來源隔離標頭。正式託管若改用多執行緒版，則需另行設定相應 COOP/COEP 標頭。
