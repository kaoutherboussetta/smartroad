# Backend SmartRoad

## تشغيل السيرفر

```bash
cd backend
npm start
```

يجب أن ترى: **Server running on port 3000**

## اختبار سريع

افتح في المتصفح: **http://localhost:3000**

- إذا ظهر **API Working ✅** → السيرفر شغال ✅  
- إذا ظهر **This site can't be reached** → السيرفر مش شغال (شغّل `npm start` من مجلد `backend`)

## ملاحظة

- الـ Frontend (Flutter) يستخدم `http://localhost:3000` — تأكد أن الرقم 3000 نفسه في `server.js`.
- كل الـ routes ترجع JSON (`res.json`) وليس HTML.
