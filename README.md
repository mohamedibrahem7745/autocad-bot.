# autocad-bot.
اوتوكاد بوت

## إزاي بيشتغل
- `commands.scr`: أوامر الرسمة (AutoCAD script).
- `bridge/autocad-bridge.ps1`: وسيط بيشتغل على الجهاز، بيراقب فولدر `inbox` جنبه، وأي ملف `.scr` يتحط فيه يتنفذ تلقائياً في الرسمة المفتوحة في الأوتوكاد، وبعدين يتنقل لفولدر `done`. السجل في `bridge.log`.

## التشغيل لأول مرة
1. حط ملفات فولدر `bridge` في `Documents\autocad-bot` على الجهاز.
2. افتح `start-bridge.bat` مرة واحدة واسيب الشباك مفتوح.
3. أي `.scr` يتحط في `Documents\autocad-bot\inbox` هيترسم لوحده.
