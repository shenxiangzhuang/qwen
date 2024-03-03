import Qwen.Sigils
alias Qwen.Image


image_prompt = ~p"model: wanx-v1 prompt: 一只奔跑的猫 parameters.style: <chinese painting> parameters.size: 1024*1024 parameters.n: 1 parameters.seed: 42"
task_id = image_prompt |> Image.post_async_generation_task |> Image.parse_task_id
image_url = task_id |> Image.get_task_status
