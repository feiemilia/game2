# 小小夢魔：星光理財島

一款原創的 Godot 4 兒童生活理財冒險遊戲，以溫暖夢境與微微神祕的氛圍呈現。

## 開始遊戲

雙擊 `Run_Game.bat`，或使用 Godot 4.7 開啟此資料夾中的 `project.godot` 後執行專案。標題畫面按 Enter 或點選開始。

- 方向鍵或 A / D：移動
- 空白鍵、W 或 ↑：跳躍
- 靠近發光挑戰站後按 E，或點畫面上的挑戰提示
- 畫面下方左右鍵每按一次前進一小步，跳躍鍵可點按

## 關卡與學習目標

1. **月光市集**：零用錢規劃與先存後花。答對互動題才能取得月光鑰匙。
2. **星星果園**：分散投資與了解風險。答對互動題才能取得星星鑰匙。

收集星星果實可為各關加分。完成後會顯示總分、關卡分數，以及從冒險起點到完成兩項學習目標的進步成果。遊戲提醒兒童投資有風險，沒有保證獲利。

## 3D 主角

`blender/dream_sprite.blend` 是原創小夢精靈的 Blender 場景；`blender/dream_sprite.glb` 可匯入 Godot 或其他 3D 工具。建模腳本位於 `blender/create_dream_sprite.py`。

此電腦的 Intel Core Ultra 5 325 支援 SSE4.2 與 AVX2；原有 Blender 5.3 卻以非法指令狀態退出。為了產生模型，我在本專案附上 Blender 官方 4.5.3 LTS 可攜版作為相容工作版本。可用以下命令重跑建模腳本：

```powershell
.\blender\portable-4.5.3\blender-4.5.3-windows-x64\blender.exe -b --python .\blender\create_dream_sprite.py
```

## 場景美術方向

兩關都改為室內夢境房間：冷色窗光、舊木地板、玩具推車、書架、月亮吊飾、暖色提燈與三燈機關門。氣氛保留神祕的童年冒險感，並以柔和燈光、可愛小精靈與非暴力謎題維持兒童友善。場景元素皆為本專案原創繪製，沒有使用參考作品的角色或素材。

## 執行流程測試

在專案根目錄執行以下命令，會檢查兩關、觸控移動、果實計分、答錯重試、鑰匙解鎖與結算：

```powershell
C:\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/flow_smoke.gd
```

## 需求與驗收追蹤

| 需求 | 實作 | 驗收證據 |
| --- | --- | --- |
| 兩關生活理財與投資學習 | 月光市集教零用錢規劃；星星果園教分散投資與風險 | `tests/flow_smoke.gd` 進入兩關互動題 |
| 解題後才能取得 KEY | 每關答錯可重試；答對才設定該關鑰匙 | 流程測試確認錯答不計分、正答發鑰匙 |
| 每關顯示得分、結尾呈現進步 | HUD 顯示關卡分數與總分；結算頁顯示 0/2 至 2/2 學習目標 | 流程測試核對兩關分數、總分與結算狀態 |
| Godot 專案可直接啟動 | `Run_Game.bat` 呼叫本機 Godot 4.7.2 | Godot 4.7.2 已啟動畫面並載入第一關；流程測試通過 |
| 使用 Blender 製作 3D 主角 | `blender/dream_sprite.blend` 與 `dream_sprite.glb` | Blender 4.5.3 LTS 開啟場景成功，含 21 個場景物件 |

## 本機網頁版

`web-export/` 是 Godot 4.7.2 產生的 Web Release。執行 `Run_Web_Preview.ps1` 可在 `http://127.0.0.1:8000/` 預覽；執行 `Export_Web.ps1` 可重新匯出（需本機保留 `.godot-web-runtime` 中的 Web 範本）。

## GitHub Pages 部署

推送 `main` 後，`.github/workflows/deploy-pages.yml` 會把 `web-export/` 發布到 GitHub Pages。預期網址：<https://feiemilia.github.io/game2/>。本次已推送專案和 Web 匯出，首次 workflow 因 Pages 尚未啟用而停在 Configure GitHub Pages。請在 [Repository Settings → Pages](https://github.com/feiemilia/game2/settings/pages) 將 Source 設為 **GitHub Actions**，再到 [Actions](https://github.com/feiemilia/game2/actions/workflows/deploy-pages.yml) 重新執行 workflow。遊戲概念 B、C、E′仍待使用者選擇，目前 Web 預覽是現有玩法 A。
