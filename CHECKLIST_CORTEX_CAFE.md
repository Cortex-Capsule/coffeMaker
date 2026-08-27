# Checklist - Start do Projeto Cortex Cafe

Use este checklist como roteiro operacional para sair do plano e chegar nas primeiras demonstracoes confiaveis. A primeira meta e validar a bancada, cameras, leader/follower e gravar a habilidade H2: pegar a xicara e posiciona-la na base da Nespresso.

## 0. Decisoes iniciais

- [ ] Confirmar que a primeira habilidade sera H2: posicionar xicara.
- [ ] Definir o modelo unico de xicara da fase inicial.
- [ ] Definir a posicao fixa da maquina Nespresso na bancada.
- [ ] Definir a posicao fixa da bandeja de xicaras.
- [ ] Definir a posicao segura de repouso `home` do braco.
- [ ] Registrar uma foto da bancada montada corretamente.
- [ ] Criar uma pasta local para notas de sessao, falhas e ajustes.

## 1. Seguranca antes de energizar

- [ ] Confirmar que existe botao de emergencia fisico acessivel.
- [ ] Confirmar forma clara de cortar a alimentacao dos servos.
- [ ] Remover pessoas, animais, cabos soltos e objetos frageis da area de movimento.
- [ ] Fixar ou estabilizar a maquina Nespresso.
- [ ] Usar bandeja estavel e base antiderrapante.
- [ ] Testar movimentos inicialmente com a maquina desligada.
- [ ] Testar sem capsula.
- [ ] Testar sem liquido quente.
- [ ] Garantir que ninguem coloque a mao na area de movimento com o follower energizado.
- [ ] Definir uma frase ou comando manual de parada durante testes.

## 2. Preparar a bancada

- [ ] Marcar com fita a posicao da maquina.
- [ ] Marcar com fita a posicao da bandeja de xicaras.
- [ ] Marcar a posicao alvo da xicara na base da maquina.
- [ ] Marcar a posicao `home` do braco.
- [ ] Conferir se a xicara esta dentro do alcance seguro do follower.
- [ ] Conferir se a base da maquina esta dentro do alcance seguro do follower.
- [ ] Remover reflexos fortes na area da xicara.
- [ ] Manter iluminacao constante.
- [ ] Tirar uma foto de referencia da bancada pronta.

## 3. Conferir hardware

- [ ] Conectar follower SO-101.
- [ ] Conectar leader SO-101.
- [ ] Confirmar porta do follower, esperada: `/dev/ttyACM1`.
- [ ] Confirmar porta do leader, esperada: `/dev/ttyACM0`.
- [ ] Conectar camera ampla, esperada: `/dev/video2`.
- [ ] Conectar camera garra/xicara, esperada: `/dev/video0`.
- [ ] Conectar camera compartimento/botao, esperada: `/dev/video4`.
- [ ] Confirmar que nenhuma camera mudou de indice apos reconectar USB.
- [ ] Calibrar leader.
- [ ] Calibrar follower.
- [ ] Testar movimento pequeno e lento antes de qualquer demonstracao.

## 4. Conferir software

- [ ] Abrir terminal no projeto:

```bash
cd "/media/jonathan/Jonathan_s Files/_coding/LerobotDemo"
```

- [ ] Ativar o ambiente Python usado pelo LeRobot.
- [ ] Confirmar que o comando `lerobot-record` esta disponivel.
- [ ] Confirmar que as cameras aparecem no sistema.
- [ ] Confirmar que o display local esta livre na porta `9877`.
- [ ] Revisar o comando base em `PASSO_A_PASSO.md`.
- [ ] Fazer um teste rapido sem gravar dataset definitivo.

## 5. Testar cameras

- [ ] Verificar camera ampla.
- [ ] Verificar camera garra/xicara.
- [ ] Verificar camera compartimento/botao.
- [ ] Confirmar foco suficiente para ver a garra.
- [ ] Confirmar foco suficiente para ver a xicara na bandeja.
- [ ] Confirmar foco suficiente para ver a xicara na base da maquina.
- [ ] Confirmar que o braco nao bloqueia todas as cameras durante a tarefa.
- [ ] Salvar imagens de referencia das tres cameras.

## 6. Ensaio seco da H2

- [ ] Colocar follower em `home`.
- [ ] Colocar xicara na posicao inicial da bandeja.
- [ ] Manter maquina desligada.
- [ ] Executar a trajetoria com leader sem iniciar gravacao.
- [ ] Confirmar que a garra alcanca a xicara sem bater na bandeja.
- [ ] Confirmar que a xicara pode ser levantada sem escorregar.
- [ ] Confirmar que a trajetoria ate a base nao cruza areas de risco.
- [ ] Confirmar que a xicara fica centrada na base.
- [ ] Repetir ate o movimento ficar lento, suave e previsivel.

## 7. Gravar dataset H2

- [ ] Usar dataset `ilustraviz/cortex-cafe-xicara`.
- [ ] Usar tarefa: `posicionar xicara na base da Nespresso`.
- [ ] Comecar com 30 episodios.
- [ ] Gravar demonstracoes lentas e suaves.
- [ ] Salvar apenas demonstracoes boas com `->`.
- [ ] Descartar demonstracoes ruins com `<-`.
- [ ] Variar levemente a posicao inicial da xicara.
- [ ] Nao mudar a organizacao geral da bancada.
- [ ] Pausar se houver colisao, travamento, oclusao forte ou xicara mal presa.

Comando base para H2:

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
    --dataset.repo_id=ilustraviz/cortex-cafe-xicara \
    --dataset.num_episodes=30 \
    --dataset.single_task="posicionar xicara na base da Nespresso"
```

## 8. Revisar demonstracoes H2

- [ ] Revisar videos antes de treinar.
- [ ] Remover episodios com oclusao critica.
- [ ] Remover episodios com colisao.
- [ ] Remover episodios com xicara escorregando.
- [ ] Remover episodios com correcao brusca.
- [ ] Remover episodios em que a xicara termina fora do centro.
- [ ] Contar quantos episodios limpos sobraram.
- [ ] Se sobrarem menos de 30, gravar mais demonstracoes.

## 9. Treinar primeira politica H2

- [ ] Treinar uma politica ACT apenas para H2.
- [ ] Registrar parametros usados no treino.
- [ ] Salvar caminho do checkpoint.
- [ ] Salvar logs e metricas do treino.
- [ ] Nao integrar com voz ainda.
- [ ] Nao operar maquina quente ainda.

## 10. Avaliar H2

- [ ] Avaliar primeiro sem xicara, se o modo permitir.
- [ ] Avaliar com xicara resistente.
- [ ] Fazer 20 tentativas controladas.
- [ ] Registrar sucesso ou falha de cada tentativa.
- [ ] Registrar causa de cada falha.
- [ ] Meta minima: 18 sucessos em 20 tentativas consecutivas.
- [ ] Se falhar por visao, ajustar cameras e regravar dados.
- [ ] Se falhar por garra, ajustar pegada e regravar dados.
- [ ] Se falhar por trajetoria, reduzir variacao e regravar dados.

## 11. So depois da H2

- [ ] Planejar H1: abrir compartimento.
- [ ] Planejar H3: inserir capsula.
- [ ] Planejar H4: fechar compartimento.
- [ ] Planejar H5: pressionar botao.
- [ ] Manter datasets separados por habilidade.
- [ ] Exigir confirmacao humana antes do botao de preparo nas primeiras versoes.
- [ ] Integrar voz somente depois da maquina de estados supervisionada existir.

## Log rapido de sessoes

| Data | Objetivo | Episodios bons | Principal falha | Proximo ajuste |
|---|---:|---:|---|---|
| | | | | |

## Pronto para seguir quando

- [ ] Bancada repetivel e fotografada.
- [ ] Portas e cameras confirmadas.
- [ ] Emergency stop testado.
- [ ] Movimento H2 ensaiado sem gravacao.
- [ ] 30 demonstracoes H2 limpas gravadas.
- [ ] Videos revisados.
- [ ] Primeira politica H2 treinada.
- [ ] H2 avaliada com pelo menos 18/20 sucessos.
