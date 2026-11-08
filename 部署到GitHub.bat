@echo off
chcp 65001 >nul
cd /d "%~dp0"
if errorlevel 1 goto directory_error
setlocal DisableDelayedExpansion
where git >nul 2>&1
if errorlevel 1 goto git_error
set "DEPLOY_WORKTREE="
for /f "delims=" %%W in ('git rev-parse --is-inside-work-tree 2^>nul') do set "DEPLOY_WORKTREE=%%W"
if not "%DEPLOY_WORKTREE%"=="true" goto repository_error
set "DEPLOY_BRANCH="
for /f "delims=" %%B in ('git rev-parse --abbrev-ref HEAD') do set "DEPLOY_BRANCH=%%B"
if not defined DEPLOY_BRANCH goto branch_error
if "%DEPLOY_BRANCH%"=="HEAD" goto branch_error
set "DEPLOY_URL=https://github.com/Nimbo-Cool/sudoku-maze.git"
git remote get-url origin >nul 2>&1
if errorlevel 1 goto add_origin
goto check_origin
:add_origin
git remote add origin "%DEPLOY_URL%"
if errorlevel 1 goto remote_error
:check_origin
for /f "delims=" %%U in ('git remote get-url --all origin') do if not "%%U"=="%DEPLOY_URL%" if not "%%U"=="https://github.com/Nimbo-Cool/sudoku-maze" goto remote_mismatch
for /f "delims=" %%U in ('git remote get-url --push --all origin') do if not "%%U"=="%DEPLOY_URL%" if not "%%U"=="https://github.com/Nimbo-Cool/sudoku-maze" goto remote_mismatch
git add -A
if errorlevel 1 goto add_error
git diff --cached --quiet
if errorlevel 2 goto diff_error
if errorlevel 1 goto commit_changes
echo 沒有新的變更，直接推送。
goto push_changes
:commit_changes
set "DEPLOY_MESSAGE="
for /f "delims=" %%T in ('powershell -NoProfile -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; ([char]0x66f4).ToString() + [char]0x65b0 + ' ' + (Get-Date -Format 'yyyy-MM-dd HH:mm')"') do set "DEPLOY_MESSAGE=%%T"
if not defined DEPLOY_MESSAGE goto date_error
git commit -m "%DEPLOY_MESSAGE%"
if errorlevel 1 goto commit_error
:push_changes
git push -u origin "%DEPLOY_BRANCH%"
if errorlevel 1 goto push_error
echo 部署成功，已推送目前分支。
pause
exit /b 0
:directory_error
echo 無法進入批次檔所在資料夾。
goto failed
:git_error
echo 找不到 Git，請先安裝 Git 並確認 git 指令可執行。
goto failed
:repository_error
echo 目前資料夾不是可用的 Git 工作區。
goto failed
:branch_error
echo 無法取得目前分支，或目前為分離 HEAD 狀態，請先手動切回要部署的分支。
goto failed
:remote_error
echo 無法新增 origin，請查看上方 Git 錯誤訊息。
goto failed
:remote_mismatch
echo origin 的讀取或推送網址與指定專案不同，已停止且未修改遠端設定。
git remote -v
echo 請先確認網址，再手動使用 git remote set-url origin 設定正確網址；另有推送網址時也需手動確認。
goto failed
:add_error
echo 無法加入變更，請查看上方 Git 錯誤訊息。
goto failed
:diff_error
echo 無法檢查暫存變更，請查看上方 Git 錯誤訊息。
goto failed
:date_error
echo 無法透過 PowerShell 取得提交訊息，已停止。
goto failed
:commit_error
echo 提交失敗，請查看上方原因。若缺少身分設定，請先執行下列指令並填入自己的資料：
echo git config user.name "Your Name"
echo git config user.email "you@example.com"
goto failed
:push_error
echo 推送失敗，請查看上方 Git 原因。請確認 GitHub 登入權限與網路連線。
echo 若遠端已有本機沒有的提交，請先手動 git pull 並處理差異，再重新執行本批次檔。
goto failed
:failed
pause
exit /b 1
