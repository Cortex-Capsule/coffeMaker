# LeRobot Demo — Passo a Passo (LeRobot v0.6.0)

## Checklist de Progresso

- [x] 1. Instalar Miniforge3 (Mamba/Conda)
- [x] 2. Criar ambiente virtual com Python 3.12
- [x] 3. Ativar o ambiente
- [x] 4. Instalar FFmpeg 7.x
- [ ] 5. Atualizar LeRobot para v0.6.0
- [ ] 6. Instalar extras de scripts, treino e Feetech
- [x] 7. Login no HuggingFace (user: ilustraviz)
- [x] 8. Encontrar portas USB dos braços
- [x] 9. Calibrar braços (follower + leader)
- [x] 10. Teleoperação (testar braços)
- [x] 11. Encontrar câmeras
- [x] 12. Gravar demonstrações (recording)
- [x] 13. Replay (repetir episódio)
- [x] 14. Treinar política (ACT)
- [ ] 15. Executar rollout autônomo no robô real ← **PRÓXIMO**
- [ ] 16. Avaliar episódios e coletar correções DAgger
- [ ] 17. Re-treinar e repetir o ciclo

---

## Configuração do Hardware

| Dispositivo | Porta | Notas |
|-------------|-------|-------|
| Follower arm | `/dev/ttyACM1` | so101_follower, id: my_awesome_follower_arm |
| Leader arm | `/dev/ttyACM0` | so101_leader, id: my_awesome_leader_arm |
| Camera #0 | `/dev/video0` | 640x480 @ 30fps, OpenCV |
| Camera #1 | `/dev/video2` | 640x480 @ 30fps, OpenCV |
| Camera #2 | `/dev/video4` | 640x480 @ 30fps, OpenCV (câmera do follower) |

> **IMPORTANTE:** As portas podem mudar ao reconectar. Usar `lerobot-find-port` para verificar.

---

## Comandos Rápidos (para retomar)

```bash
# Ativar ambiente (sempre necessário em novos terminais)
source ~/.bashrc && mamba activate lerobot
cd "/media/jonathan/Jonathan_s Files/_coding/LerobotDemo/lerobot"
```

---

## 1. Instalar Miniforge3 (Mamba/Conda)

```bash
# Baixar o instalador (já feito)
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh

# Executar o instalador
bash Miniforge3-Linux-x86_64.sh
```

> Após a instalação, fechar e reabrir o terminal (ou rodar `source ~/.bashrc`).

---

## 2. Criar o ambiente virtual com Python 3.12

```bash
mamba create -y -n lerobot python=3.12
```

---

## 3. Ativar o ambiente

```bash
mamba activate lerobot
source ~/.bashrc && mamba activate lerobot
```

> **Nota:** Em cada novo terminal, pode ser necessário rodar `source ~/.bashrc` antes.

---

## 4. Instalar FFmpeg

```bash
# Instalar pelo Conda (necessário para PyTorch anterior ao 2.10)
mamba install -y ffmpeg -c conda-forge

# Verificar a versão
ffmpeg -version
```

> No LeRobot v0.6, o TorchCodec e PyTorch >= 2.10 também suportam FFmpeg do sistema. No ambiente Conda, manter o FFmpeg instalado no ambiente é o caminho mais previsível.

---

## 5. Atualizar o LeRobot para v0.6.0 (from source)

```bash
# O checkout atual esta em v0.5.1. Atualizar para a tag da nova versao.
git fetch --tags origin
git checkout v0.6.0

# Verificar instalação
python -c "import lerobot; print(lerobot.__version__)"  # 0.6.0
```

> O `git checkout v0.6.0` deixa o repositório em uma tag (detached HEAD), adequado para uma instalação estável. Para desenvolver mudanças no LeRobot, crie uma branch a partir da tag.

---

## 6. Instalar extras necessários

```bash
# Scripts de robô (record, replay, calibrate e rollout), treino e motores Feetech.
pip install -e '.[core_scripts,training,feetech]'

# Verificar o novo CLI de implantação.
lerobot-rollout --help
```

> A instalação base ficou menor no v0.6. Os extras agora são obrigatórios para cada fluxo: `core_scripts` para o robô, `training` para ACT e `feetech` para os motores SO-101.

---

## 7. Login no HuggingFace

```bash
# Opção 1 (CLI)
hf auth login

# Opção 2 (via Python)
python -c "from huggingface_hub import login; login()"
```

> 1. Criar conta em https://huggingface.co/join (se ainda não tiver)
> 2. Gerar token em https://huggingface.co/settings/tokens
> 3. Colar o token quando solicitado
> 4. Responder `Y` para "Add token as git credential?"

---

## 8. Encontrar portas USB dos braços

```bash
# Conectar o adaptador servo via USB + alimentação, depois rodar:
lerobot-find-port

# Quando solicitado, desconectar o adaptador
# Anotar a porta (ex: /dev/ttyUSB0)
# Repetir para cada braço (leader e follower)
```

---

## 9. Calibrar os braços

```bash
# Calibrar o braço FOLLOWER
lerobot-calibrate \
    --robot.type=so101_follower \
    --robot.port=/dev/ttyACM1 \
    --robot.id=my_awesome_follower_arm

# Calibrar o braço LEADER (usa --teleop, não --robot)
lerobot-calibrate \
    --teleop.type=so101_leader \
    --teleop.port=/dev/ttyACM0 \
    --teleop.id=my_awesome_leader_arm
```

> Portas encontradas:
> - Follower: `/dev/ttyACM1`
> - Leader: `/dev/ttyACM0`
>
> Siga as instruções na tela para mover os motores nas posições corretas.

---

## 10. Teleoperação (testar os braços)

```bash
lerobot-teleoperate \
    --robot.type=so101_follower \
    --robot.port=/dev/ttyACM1 \
    --robot.id=my_awesome_follower_arm \
    --teleop.type=so101_leader \
    --teleop.port=/dev/ttyACM0 \
    --teleop.id=my_awesome_leader_arm
```

> Mova o braço leader e o follower acompanha em tempo real.
> Pressione `Ctrl+C` para parar.

---

## 11. Encontrar câmeras

```bash
lerobot-find-cameras
```

> Câmeras detectadas:
> - Camera #0: `/dev/video0` (640x480 @ 30fps)
> - Camera #1: `/dev/video2` (640x480 @ 30fps)
>
> O erro de RealSense pode ser ignorado (não há câmera Intel RealSense conectada).

---

## 12. Gravar demonstrações (Recording/Training Data)

### Abrir a interface ao vivo (Rerun)

Neste computador, a porta padrão do Rerun (`9876`) é usada pelo Blender. Antes de gravar, abra outro terminal e inicie um viewer Rerun dedicado nas portas `9877` e `9091`:

```bash
source ~/.bashrc && mamba activate lerobot
rerun --web-viewer --port 9877 --web-viewer-port 9091 --bind 127.0.0.1 --expect-data-soon
```

Mantenha esse terminal aberto e abra no navegador: `http://127.0.0.1:9091?url=rerun%2Bhttp%3A%2F%2Flocalhost%3A9877%2Fproxy`.

### Iniciar a gravação

```bash
lerobot-record \
    --robot.type=so101_follower \
    --robot.port=/dev/ttyACM1 \
    --robot.id=my_awesome_follower_arm \
    --robot.cameras='{"camera1": {"type": "opencv", "index_or_path": "/dev/video2", "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}, "camera2": {"type": "opencv", "index_or_path": "/dev/video0", "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}, "camera3": {"type": "opencv", "index_or_path": "/dev/video4", "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}}' \
    --teleop.type=so101_leader \
    --teleop.port=/dev/ttyACM0 \
    --teleop.id=my_awesome_leader_arm \
    --display_data=true \
    --display_ip=127.0.0.1 \
    --display_port=9877 \
    --dataset.repo_id=ilustraviz/firstrainlerobot \
    --dataset.num_episodes=5 \
    --dataset.single_task="pick_and_place" \
    --resume=true
```

> HuggingFace repo: `ilustraviz/firstrainlerobot`
> Use o leader arm para demonstrar a tarefa. Cada episódio é gravado separadamente.
>
> **Interface ao vivo:** `--display_data=true` envia `camera1`, `camera2`, `camera3`, posições das juntas e ações ao Rerun. Os parâmetros `--display_ip=127.0.0.1` e `--display_port=9877` conectam ao viewer dedicado iniciado acima, sem interferir no Blender.
>
> **Controles durante a gravação:**
> - `→` (seta para a direita): encerra, salva o episódio atual e passa ao período de reset antes do próximo episódio.
> - `←` (seta para a esquerda): descarta o episódio atual e permite gravá-lo novamente.
> - `Esc`: encerra toda a sessão sem salvar o episódio em andamento; episódios já salvos permanecem no dataset.
> - Não há tecla de pausa nesta versão. Para parar imediatamente pelo terminal, use `Ctrl+C`; trate o episódio atual como descartado.
>
> A interface é configurada ao iniciar o `lerobot-record`; não é possível ativá-la em uma gravação já iniciada com `--display_data=false`. Termine os episódios atuais antes de parar o processo e reiniciá-lo com `--display_data=true`.
>
> **Retomar o dataset existente:** mantenha `--resume=true` e as três câmeras exatamente como acima. Não apague o cache para continuar o dataset: isso pode remover os dados locais pendentes de envio. Use a mesma lista de câmeras porque o schema do dataset existente inclui `camera1`, `camera2` e `camera3`.

---

## 13. Replay (repetir episódio gravado)

```bash
lerobot-replay \
    --robot.type=so101_follower \
    --robot.port=/dev/ttyACM1 \
    --robot.id=my_awesome_follower_arm \
    --dataset.repo_id=ilustraviz/firstrainlerobot \
    --dataset.episode=0
```

> O follower vai repetir automaticamente o episódio gravado.
> Trocar `--dataset.episode=0` para reproduzir outros episódios (0, 1, 2...).

---

## 14. Treinar política (ACT)

```bash
lerobot-train \
    --dataset.repo_id ilustraviz/firstrainlerobot \
    --dataset.video_backend pyav \
    --policy.type act \
    --output_dir outputs/train/act_training \
    --batch_size 8 \
    --steps 50000 \
    --save_checkpoint true \
    --save_freq 2500 \
    --wandb.enable true \
    --wandb.project lerobot_training \
    --policy.device cuda \
    --policy.use_amp true \
    --policy.chunk_size 50 \
    --policy.n_action_steps 50 \
    --policy.repo_id ilustraviz/firstrainlerobot_policy \
    --policy.push_to_hub true
```

> **Notas:**
> - Usa GPU NVIDIA RTX 3080 (`--policy.device cuda`)
> - 50.000 steps, salva checkpoint a cada 2.500
> - Política será salva no HuggingFace: `ilustraviz/firstrainlerobot_policy`
 - Para usar Weights & Biases: `pip install wandb && wandb login` e trocar `--wandb.enable true`

---

## 15. Rollout autônomo no robô real

```bash
# Executa a política por 60 segundos, sem gravar. Use para validar a segurança
# e observar a qualidade antes de gravar episódios de avaliação.
lerobot-rollout \
    --strategy.type=base \
    --robot.type=so101_follower \
    --robot.port=/dev/ttyACM1 \
    --robot.id=my_awesome_follower_arm \
    --robot.cameras='{"camera1": {"type": "opencv", "index_or_path": "/dev/video2", "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}, "camera2": {"type": "opencv", "index_or_path": "/dev/video0", "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}, "camera3": {"type": "opencv", "index_or_path": "/dev/video4", "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}}' \
    --policy.path=ilustraviz/firstrainlerobot_policy \
    --device=cuda \
    --task="pick_and_place" \
    --duration=60 \
    --display_data=true
```

> No v0.6, `lerobot-rollout` substitui o uso de `lerobot-record` para implantar políticas. A estratégia `base` não grava dados e é a opção indicada para o primeiro teste de segurança.

---

## 16. Gravar episódios de avaliação autônoma

```bash
lerobot-rollout \
    --strategy.type=episodic \
    --robot.type=so101_follower \
    --robot.port=/dev/ttyACM1 \
    --robot.id=my_awesome_follower_arm \
    --robot.cameras='{"camera1": {"type": "opencv", "index_or_path": "/dev/video2", "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}, "camera2": {"type": "opencv", "index_or_path": "/dev/video0", "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}, "camera3": {"type": "opencv", "index_or_path": "/dev/video4", "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}}' \
    --teleop.type=so101_leader \
    --teleop.port=/dev/ttyACM0 \
    --teleop.id=my_awesome_leader_arm \
    --policy.path=ilustraviz/firstrainlerobot_policy \
    --device=cuda \
    --dataset.repo_id=ilustraviz/eval_firstrainlerobot \
    --dataset.num_episodes=10 \
    --dataset.episode_time_s=30 \
    --dataset.reset_time_s=15 \
    --dataset.single_task="pick_and_place" \
    --display_data=true
```

> A política controla cada episódio; o leader é usado apenas durante o reset entre episódios. `→` encerra o episódio atual, `←` descarta e regrava, e `ESC` encerra a sessão. Inspecione os vídeos e registre sucesso/falha por episódio antes de usar esses dados em treino.

---

## 17. Coletar correções DAgger e repetir o ciclo

```bash
lerobot-rollout \
    --strategy.type=dagger \
    --strategy.num_episodes=20 \
    --robot.type=so101_follower \
    --robot.port=/dev/ttyACM1 \
    --robot.id=my_awesome_follower_arm \
    --robot.cameras='{"camera1": {"type": "opencv", "index_or_path": "/dev/video2", "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}, "camera2": {"type": "opencv", "index_or_path": "/dev/video0", "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}, "camera3": {"type": "opencv", "index_or_path": "/dev/video4", "width": 640, "height": 480, "fps": 30, "fourcc": "MJPG"}}' \
    --teleop.type=so101_leader \
    --teleop.port=/dev/ttyACM0 \
    --teleop.id=my_awesome_leader_arm \
    --policy.path=ilustraviz/firstrainlerobot_policy \
    --device=cuda \
    --dataset.repo_id=ilustraviz/firstrainlerobot_dagger \
    --dataset.single_task="pick_and_place"
```

> Durante o rollout, `Tab` inicia/encerra a correção humana, `Space` pausa/retoma a política, `Enter` envia as correções ao Hub e `ESC` encerra. Por padrão, o dataset guarda somente as janelas corrigidas, marcadas com `intervention=True`.

O ciclo recomendado passa a ser:

1. Gravar demonstrações limpas com `lerobot-record`.
2. Treinar ACT com `lerobot-train`.
3. Testar com `lerobot-rollout --strategy.type=base`.
4. Medir resultados com `--strategy.type=episodic`.
5. Corrigir falhas com `--strategy.type=dagger`.
6. Mesclar demonstrações e correções em um novo dataset de treino, re-treinar e voltar ao passo 3.

---