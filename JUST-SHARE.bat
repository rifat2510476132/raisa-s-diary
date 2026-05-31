@echo off
chcp 65001 >nul
title Raisa's Diary - Link বানান
color 0D
echo.
echo  ============================================
echo   Jannatul Maowa Raisa's Diary
echo   ২ মিনিটে SHARE লিংক বানান (FREE)
echo  ============================================
echo.
echo  ধাপ ১: ব্রাউজারে Netlify Drop খুলছি...
echo  ধাপ ২: share-web ফোল্ডার খুলছি...
echo.
echo  আপনি যা করবেন:
echo    → share-web ফোল্ডারটা Netlify তে আবার drop করুন (v3)
echo    → পুরনো site থাকলে অবশ্যই নতুন করে drop করুন!
echo    → ব্রাউজারে Ctrl+Shift+R চাপুন
echo    → PASSWORD নেই — শুধু "শুরু করুন" চাপলেই ঢুকবে
echo.
start https://app.netlify.com/drop
explorer "%~dp0share-web"
echo.
echo  (অথবা এই ফোল্ডারে share-web.zip আছে — সেটাও drop করতে পারেন)
if exist "%~dp0dist\share-web.zip" explorer "%~dp0dist"
echo.
pause
