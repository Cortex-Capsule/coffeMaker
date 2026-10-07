#!/bin/bash
# ============================================================================
# SETUP COMPLETO PARA ROLLAR FLUX3 capsula->copo NO THINKBOOK (Linux)
# ============================================================================
# Como usar:
#   1. Copie este arquivo para o ThinkBook (email/pendrive/ssh)
#   2. No ThinkBook:
#        chmod +x setup_rollout_thinkbook.sh
#        ./setup_rollout_thinkbook.sh
#   3. Ele vai pedir seu token do HuggingFace se ainda não estiver logado.
#
# Pré-requisitos no ThinkBook:
#   - lerobot instalado em ~/Documents/coding/lerobot (venv com uv)
#   - Braços SO-101 conectados via USB
#   - GPU RTX 3090 funcionando (nvidia-smi ok)
#   - Internet para baixar o checkpoint do HF
#
# ============================================================================

set -euo pipefail

echo "=== [1/5] Verificando pré-requisitos ==="

if ! command -v nvidia-smi &>/dev/null; then
    echo "ERRO: nvidia-smi não encontrado. GPU não reconhecida."
    exit 1
fi
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader

if [ ! -d ~/Documents/coding/lerobot/.venv ]; then
    echo "ERRO: venv do lerobot não encontrado em ~/Documents/coding/lerobot/.venv"
    exit 1
fi

source ~/Documents/coding/lerobot/.venv/bin/activate
python -c "import torch; print('torch:', torch.__version__, 'cuda:', torch.cuda.is_available())"

python - <<'PYEOF'
try:
    import natten
    print('natten ok')
except ImportError:
    print('natten NAO instalado — instalando agora pode falhar sem headers cuda.')
PYEOF

echo ""
echo "=== [2/5] Criando calibração dos braços ==="

mkdir -p ~/.cache/huggingface/lerobot/calibration/robots/so_follower
mkdir -p ~/.cache/huggingface/lerobot/calibration/teleoperators/so_leader

cat > ~/.cache/huggingface/lerobot/calibration/robots/so_follower/my_awesome_follower_arm.json <<'FOLLOWER_EOF'
{
    "shoulder_pan": {"id":1,"drive_mode":0,"homing_offset":854,"range_min":1149,"range_max":2828},
    "shoulder_lift": {"id":2,"drive_mode":0,"homing_offset":-65,"range_min":887,"range_max":3240},
    "elbow_flex": {"id":3,"drive_mode":0,"homing_offset":-41,"range_min":855,"range_max":3073},
    "wrist_flex": {"id":4,"drive_mode":0,"homing_offset":-635,"range_min":912,"range_max":3223},
    "wrist_roll": {"id":5,"drive_mode":0,"homing_offset":-592,"range_min":0,"range_max":4095},
    "gripper": {"id":6,"drive_mode":0,"homing_offset":-1705,"range_min":2033,"range_max":3526}
}
FOLLOWER_EOF

cat > ~/.cache/huggingface/lerobot/calibration/teleoperators/so_leader/my_awesome_leader_arm.json <<'LEADER_EOF'
{
    "shoulder_pan": {"id":1,"drive_mode":0,"homing_offset":672,"range_min":1176,"range_max":2785},
    "shoulder_lift": {"id":2,"drive_mode":0,"homing_offset":-10,"range_min":932,"range_max":3294},
    "elbow_flex": {"id":3,"drive_mode":0,"homing_offset":1189,"range_min":862,"range_max":3071},
    "wrist_flex": {"id":4,"drive_mode":0,"homing_offset":1107,"range_min":864,"range_max":3164},
    "wrist_roll": {"id":5,"drive_mode":0,"homing_offset":-232,"range_min":0,"range_max":4095},
    "gripper": {"id":6,"drive_mode":0,"homing_offset":-1318,"range_min":2042,"range_max":3225}
}
LEADER_EOF

echo "Calibração salva em ~/.cache/huggingface/lerobot/calibration/"

echo ""
echo "=== [3/5] Verificando portas seriais e câmeras ==="

echo "Portas seriais esperadas:"
ls -l /dev/serial/by-id/ || echo "Nenhum /dev/serial/by-id/ encontrado"
echo ""
echo "Câmeras esperadas:"
ls -l /dev/v4l/by-id/ || echo "Nenhum /dev/v4l/by-id/ encontrado"

# A partir dos números de série:
#   5B14111449 = my_awesome_follower_arm (ttyACM0)
#   5B14110823 = my_awesome_leader_arm   (ttyACM1)
FOLLOWER_PORT="/dev/ttyACM0"
LEADER_PORT="/dev/ttyACM1"

for p in $FOLLOWER_PORT $LEADER_PORT; do
    if [ -e "$p" ]; then
        echo "OK: $p existe"
    else
        echo "AVISO: $p não existe. Verifique mapeamento USB."
    fi
done

CAM_SCENE="/dev/v4l/by-id/usb-8SSC21M22245V15RD3J002F_Integrated_Camera_0001-video-index0"
CAM_WRIST="/dev/v4l/by-id/usb-046d_Logitech_Webcam_C925e_A0CE1F9F-video-index0"

for c in "$CAM_SCENE" "$CAM_WRIST"; do
    if [ -e "$c" ]; then
        echo "OK: câmera $c existe"
    else
        echo "AVISO: câmera $c não existe"
    fi
done

echo ""
echo "=== [4/5] Baixando checkpoint do HuggingFace ==="

cd ~/Documents/coding/lerobot
mkdir -p models

if ! command -v hf &>/dev/null; then
    echo "AVISO: 'hf' não encontrado. Tentando 'huggingface-cli'..."
    HFCLI="huggingface-cli"
else
    HFCLI="hf"
fi

# Se não estiver logado, vai pedir token interativo aqui
if [ ! -d "models/flux3-capsula-copo" ]; then
    $HFCLI download ilustraviz/flux3-capsula-copo --local-dir models/flux3-capsula-copo
else
    echo "Checkpoint já existe em models/flux3-capsula-copo"
fi

echo ""
echo "=== [5/5] Criando script de rollout ==="

cat > ~/Documents/coding/lerobot/rollout_capsula.sh <<'ROLLOUT_EOF'
#!/bin/bash
# Teste da politica FLUX3 LoRA capsula->copo no braço SO-101 real.
# Uso:
#   ./rollout_capsula.sh [checkpoint]
#   padrão: 002000; opções: 002000, 002000_ema, 001000, 001000_ema

set -euo pipefail
cd /home/jonathan/Documents/coding/lerobot

CKPT="${1:-002000}"
case "$CKPT" in
  002000)      POLICY="models/flux3-capsula-copo/checkpoints/002000/pretrained_model" ;;
  002000_ema)  POLICY="models/flux3-capsula-copo/checkpoints/002000/pretrained_model_ema" ;;
  001000)      POLICY="models/flux3-capsula-copo/checkpoints/001000/pretrained_model" ;;
  001000_ema)  POLICY="models/flux3-capsula-copo/checkpoints/001000/pretrained_model_ema" ;;
  *) echo "checkpoint inválido: $CKPT"; exit 1 ;;
esac
echo ">>> Usando checkpoint: $POLICY"

# camera1 = SCENE -> câmera integrada do ThinkBook
# camera2 = WRIST -> Logitech C925e
CAM_SCENE="/dev/v4l/by-id/usb-8SSC21M22245V15RD3J002F_Integrated_Camera_0001-video-index0"
CAM_WRIST="/dev/v4l/by-id/usb-046d_Logitech_Webcam_C925e_A0CE1F9F-video-index0"

# Número de série 5B14111449 = follower, 5B14110823 = leader
FOLLOWER_PORT="/dev/ttyACM0"

.venv/bin/lerobot-rollout \
  --strategy.type=base \
  --robot.type=so101_follower \
  --robot.port="$FOLLOWER_PORT" \
  --robot.id=my_awesome_follower_arm \
  --robot.cameras="{\"camera1\": {\"type\": \"opencv\", \"index_or_path\": \"$CAM_SCENE\", \"width\": 640, \"height\": 480, \"fps\": 30, \"fourcc\": \"MJPG\"}, \"camera2\": {\"type\": \"opencv\", \"index_or_path\": \"$CAM_WRIST\", \"width\": 640, \"height\": 480, \"fps\": 30, \"fourcc\": \"MJPG\"}}" \
  --policy.path="$POLICY" \
  --device=cuda \
  --task="pegar a capsula no marcador amarelo e colocar no copo" \
  --duration=60 \
  --display_data=true \
  --display_ip=127.0.0.1 \
  --display_port=9877 \
  --rename_map="{\"observation.images.camera1\":\"observation.images.scene\",\"observation.images.camera2\":\"observation.images.wrist\"}"
ROLLOUT_EOF

chmod +x ~/Documents/coding/lerobot/rollout_capsula.sh

echo ""
echo "============================================================================"
echo "TUDO PRONTO!"
echo "============================================================================"
echo ""
echo "Para rodar o rollout:"
echo "  cd ~/Documents/coding/lerobot"
echo "  ./rollout_capsula.sh 002000_ema"
echo ""
echo "Se a policy apontar para checkpoint do HF Hub, a pasta local pode não existir."
echo "Verifique com:"
echo "  ls models/flux3-capsula-copo/checkpoints/"
echo ""
echo "Bom rollout! 🦾"
