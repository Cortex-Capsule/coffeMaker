import torch
from lerobot.policies.flux3 import Flux3Policy

base_dir = "/workspace/lerobot/models/flux-3-action-so101"
adapter_dir = "/workspace/lerobot/models/flux3-capsula-copo/checkpoints/002000/pretrained_model_ema"

torch.cuda.reset_peak_memory_stats()
free0, total = torch.cuda.mem_get_info()
print(f"VRAM total={total/2**30:.1f} GiB | livre={free0/2**30:.1f} GiB")

policy = Flux3Policy.from_pretrained(
    base_dir,
    use_peft=True,
    peft_model_id=adapter_dir,
    video_vae_id="/workspace/lerobot/models/flux-3-action-base/video_vae.safetensors",
    text_encoder_id="/workspace/lerobot/models/flux-3-action-base/text_encoder",
)
policy.to("cuda")
policy.eval()

free1, _ = torch.cuda.mem_get_info()
print(f"Pico VRAM={torch.cuda.max_memory_allocated()/2**30:.1f} GiB | livre={free1/2**30:.1f} GiB")
print(f"n_action_steps={policy.config.n_action_steps} fps={policy.config.fps}")

scene = torch.rand(1, 3, 256, 256, device="cuda")
wrist = torch.rand(1, 3, 256, 256, device="cuda")
state = torch.randn(1, 6, device="cuda")
task = ["pegar a capsula no marcador amarelo e colocar no copo"]

obs = {
    "observation.images.scene": scene,
    "observation.images.wrist": wrist,
    "observation.state": state,
    "task": task,
}

with torch.inference_mode():
    plan = policy.predict_action_chunk(obs)

print(f"actions shape={plan.shape}")
print("SMOKE INFERENCE OK")
