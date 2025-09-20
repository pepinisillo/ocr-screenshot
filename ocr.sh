#!/bin/bash
flameshot gui --raw --path /tmp/ocr-temp.png --accept-on-select 2>/dev/null

if [ -f /tmp/ocr-temp.png ]; then
  text=$(tesseract /tmp/ocr-temp.png stdout -l spa+eng 2>/dev/null)
  if [ -n "$text" ]; then
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
      echo "$text" | wl-copy
    else
      echo "$text" | xclip -selection clipboard
    fi
    notify-send "✅ OCR" "Texto copiado!" -t 2000
  else
    notify-send "❌ OCR Error" "No se detectó texto" -t 2000
  fi
  rm /tmp/ocr-temp.png
else
  notify-send "❌ OCR Error" "Captura cancelada" -t 2000
fi
