
# Verifica microfone disponível via PulseAudio
MIC_LINE=$(pactl list short sources | grep -i input | grep -i Mic | head -n1)
if [[ -z "$MIC_LINE" ]]; then
    echo "⚠️ Nenhuma fonte de áudio detectada. Verifique o microfone."
else
    echo "✅ Microfone detectado: $MIC_LINE"
fi
MIC_INDEX=$(echo "$MIC_LINE" | awk '{print $1}')
MIC_NAME=$(echo "$MIC_LINE" | awk '{print $2}')
MIC_CHANNELS=$(echo "$MIC_LINE" | awk '{print $5}' | grep -o '[0-9]\+')
MIC_FREQ=$(echo "$MIC_LINE" | awk '{print $6}' | grep -o '[0-9]\+')

echo "$MIC_FREQ" > tmp/mic_freq.txt
# echo "$MIC_NAME" > tmp/mic_name.txt
# echo "$MIC_INDEX" > tmp/mic_index.txt
echo "$MIC_CHANNELS" > tmp/mic_channels.txt
