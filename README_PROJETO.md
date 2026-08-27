# LeRobot Demo — Café Nespresso Autônomo

## Objetivo

Treinar um braço robótico SO-101 para preparar café em uma máquina Nespresso de forma totalmente autônoma, usando aprendizado por imitação (imitation learning).

## Como funciona

1. **Demonstração humana** — Um operador controla o braço líder (leader arm) para demonstrar a tarefa de fazer café, enquanto o braço seguidor (follower arm) replica os movimentos. Câmeras registram a cena.

2. **Coleta de dados** — Os movimentos e imagens são gravados como episódios de treinamento e armazenados no HuggingFace (`ilustraviz/firstrainlerobot`).

3. **Treinamento** — Uma política neural (ACT — Action Chunking with Transformers) é treinada com os dados coletados usando GPU (RTX 3080), aprendendo a mapear observações visuais em ações motoras.

4. **Rollout e avaliação** — O braço follower executa a tarefa sozinho com `lerobot-rollout`; episódios avaliados e correções humanas são gravados separadamente.

5. **Melhoria iterativa** — Quando a política falha, o operador assume temporariamente com o leader arm usando a estratégia DAgger. As correções viram novos dados para o próximo treino.

## Hardware

| Componente | Descrição |
|---|---|
| Braço follower | SO-101 (motores Feetech) — `/dev/ttyACM1` |
| Braço leader | SO-101 (teleoperação) — `/dev/ttyACM0` |
| Câmera 1 | OpenCV, 640x480 @ 30fps — `/dev/video2` |
| Câmera 2 | OpenCV, 640x480 @ 30fps — `/dev/video0` |
| GPU | NVIDIA RTX 3080 |

## Software

- **LeRobot** v0.6.0 (framework de aprendizado por imitação da Hugging Face)
- **Python** 3.12 via Miniforge3/Mamba
- **Política**: ACT (Action Chunking with Transformers)
- **Tracking**: Weights & Biases

## Tarefa: pick_and_place → café Nespresso

O robô aprende a sequência de movimentos necessários para operar a máquina Nespresso — pegar a cápsula, inserir, fechar a alavanca, posicionar a xícara e acionar o botão.

## Repositórios HuggingFace

| Repo | Conteúdo |
|---|---|
| `ilustraviz/firstrainlerobot` | Dados de demonstração (episódios gravados) |
| `ilustraviz/firstrainlerobot_policy` | Política treinada (modelo ACT) |
| `ilustraviz/eval_firstrainlerobot` | Episódios de avaliação autônoma |
| `ilustraviz/firstrainlerobot_dagger` | Correções humanas durante rollout (DAgger) |








