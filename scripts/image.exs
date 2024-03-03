import Qwen.Sigils


image_prompt = ~p"model: wanx-v1 prompt: 根据杜甫的《旅夜书怀》做一副富有意境和想象力的画 parameters.style: <chinese painting> parameters.size: 1024*1024 parameters.n: 1 parameters.seed: 42"

Qwen.text_to_image(image_prompt, "./旅夜书怀.png")
